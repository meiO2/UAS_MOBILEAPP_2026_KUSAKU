import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/chat_service.dart';
import '../../Services/ocr_service.dart';


class ChatSiPintarPage extends StatefulWidget {
  final String? initialImagePath;
  const ChatSiPintarPage({super.key, this.initialImagePath});

  @override
  State<ChatSiPintarPage> createState() => _ChatSiPintarPageState();
}

class _ChatSiPintarPageState extends State<ChatSiPintarPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _hasShownPreferences = false;

  List<String> _categoryOrder = [];
  Map<String, double> _categoryPercentages = {};
  Map<String, bool> _categoryEnabled = {};
  bool _isLoadingCategories = true;

  int? _userId;
  String _userInitial = '?';

  Map<String, int> _categoryIds = {};

  final String? initialImagePath;

  _ChatSiPintarPageState({this.initialImagePath});

  Future<void> _loadCategories(int userId) async {
    try {
      final data = await ChatService.getCategories(userId);

      final order = <String>[];
      final percentages = <String, double>{};
      final enabled = <String, bool>{};
      final ids = <String, int>{};

      for (var item in data) {
        final name = item['name'] as String;
        order.add(name);
        percentages[name] = item['percentage'];
        enabled[name] = item['enabled'];
        ids[name] = item['id'];
      }

      if (!mounted) return;
      setState(() {
        _categoryOrder = order;
        _categoryPercentages = percentages;
        _categoryEnabled = enabled;
        _categoryIds = ids;
        _isLoadingCategories = false;
      });
    } catch (e, stack) {
      print('❌ LOAD CATEGORIES ERROR: $e\n$stack');
      if (!mounted) return;
      setState(() => _isLoadingCategories = false);
      _addSiPintarMessage(text: 'Gagal memuat kategori: $e');
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');
    final name = prefs.getString('username') ?? '?';
    if (mounted) {
      setState(() {
        _userId = id;
        _userInitial = name.isNotEmpty ? name[0].toUpperCase() : '?';
      });
    }
  }

@override
  void initState() {
    super.initState();
    _init();
    if (widget.initialImagePath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleReceiptImage(widget.initialImagePath!);
      });
    }
  }

  Future<void> _init() async {
    await _loadUser();

    if (_userId != null) {
      await _loadCategories(_userId!);
    } else {
      setState(() => _isLoadingCategories = false);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _addSiPintarMessage(
        text: 'Halo pejuang rupiah! Yuk, atur finansialmu sebaik mungkin.',
      );

      if (_userId != null) {
        setState(() => _isTyping = true);
        _scrollToBottom();

        try {
          final budgetResponse = await ChatService.getInitialBudget(_userId!);

          setState(() => _isTyping = false);

          if (budgetResponse.type == 'budget_suggestion' && budgetResponse.data != null) {
            _applyBudgetSuggestion(budgetResponse.data!);
          }

          _addSiPintarMessage(
            text: "Aku sudah siapkan rekomendasi budget awal untuk kamu 😊",
            showPreferences: true,
          );
        } catch (e) {
          setState(() => _isTyping = false);
          _addSiPintarMessage(
            text: 'Ini kategori kamu saat ini. Kamu bisa atur sendiri ya! 😊',
            showPreferences: true,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addSiPintarMessage(
      {required String text, bool showPreferences = false}) {
    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isUser: false,
        showPreferences: showPreferences,
      ));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
    });
    _scrollToBottom();
    _getAIResponse(text);
  }

  void _updatePercentage(String cat, double val) {
    final total = _categoryPercentages.entries
        .where((e) =>
            e.key != cat && (_categoryEnabled[e.key] ?? false))
        .fold(0.0, (sum, e) => sum + e.value);

    if (total + val > 100) return;

    setState(() => _categoryPercentages[cat] = val);
  }

  Future<void> _getAIResponse(String userText) async {
    if (_userId == null) {
      _addSiPintarMessage(text: 'User belum terdeteksi 😕');
      return;
    }

    setState(() => _isTyping = true);
    _scrollToBottom();

    try {
      final chatResponse = await ChatService.sendMessage(_userId!, userText);

      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() => _isTyping = false);

      // Always just show the reply — chat endpoint never returns budget JSON
      _addSiPintarMessage(text: chatResponse.reply);
    } catch (e, stack) {
      print('ERROR SEND MESSAGE: $e');
      print(stack);
      if (!mounted) return;
      setState(() => _isTyping = false);
      _addSiPintarMessage(text: 'Error: $e');
    }
  }

  void _applyBudgetSuggestion(Map<String, dynamic> data) {
    setState(() {
      for (var category in data.keys) {
        final pct = (data[category] as num).toDouble();

        if (!_categoryOrder.contains(category)) {
          _categoryOrder.add(category);
        }

        _categoryPercentages[category] = pct;
        _categoryEnabled[category] = pct > 0;
      }
    });
  }

  void _onSendText() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    _addUserMessage(text);
  }

  Future<void> _onSimpanPengaturan() async {
    try {
      final payload = _categoryOrder.map((cat) => {
        "id": _categoryIds[cat],          // ← now included
        "name": cat,
        "percentage": _categoryPercentages[cat] ?? 0,
        "enabled": _categoryEnabled[cat] ?? false,
      }).toList();

      await ChatService.saveCategories(_userId!, payload);
      _addSiPintarMessage(text: 'Pengaturan kamu sudah disimpan 🎉');
    } catch (e) {
      _addSiPintarMessage(text: 'Gagal menyimpan pengaturan: $e');
    }
  }

  void _onTambahKategori() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tambah Kategori Baru',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Nama kategori...',
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child:
                const Text('Batal', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              final normalized = name.toLowerCase();

              Navigator.of(ctx).pop();

              setState(() {
                final exists = _categoryPercentages.keys
                    .any((k) => k.toLowerCase() == normalized);

                if (!exists) {
                  _categoryOrder.add(name);
                  _categoryPercentages[name] = 0;
                  _categoryEnabled[name] = true;
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D4ED8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Future<void> _onPickGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      setState(() {
        _messages.add(_ChatMessage(text: '', isUser: true, imagePath: image.path));
      });
      _scrollToBottom();

      setState(() => _isTyping = true);

      try {
        final extractedText = await OCRService.extractText(image.path);

        final prompt = '''
Teks OCR dari struk/nota/bukti belanja:

$extractedText

Analisis keuangan:
1. Total pengeluaran?
2. Kategori (makanan, belanja, transportasi, dll)?
3. Item utama dan harga?
4. Saran hemat?''';

        await _getAIResponse(prompt);
      } catch (e) {
        setState(() => _isTyping = false);
        _addSiPintarMessage(text: 'Gagal membaca gambar: $e');
      }
    }
  }

Future<void> _handleReceiptImage(String imagePath) async {
    if (mounted) {
      setState(() {
        _messages.add(_ChatMessage(text: '', isUser: true, imagePath: imagePath));
      });
      _scrollToBottom();

      setState(() => _isTyping = true);
    }

    try {
      final extractedText = await OCRService.extractText(imagePath);

      final prompt = '''
Teks OCR dari struk/nota/bukti belanja:

$extractedText

Analisis keuangan:
1. Total pengeluaran?
2. Kategori (makanan, belanja, transportasi, dll)?
3. Item utama dan harga?
4. Saran hemat?''';

      await _getAIResponse(prompt);
    } catch (e) {
      if (mounted) {
        setState(() => _isTyping = false);
        _addSiPintarMessage(text: 'Gagal membaca gambar: $e');
      }
    }
  }

  Future<void> _onTakePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null && mounted) {
      await _handleReceiptImage(image.path);
    }
  }

  Widget _siPintarAvatar({double size = 36}) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 212, 103, 255),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/sipintar/sipintar.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 23, 67, 189),
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Chat si Pintar',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 65,
              height: 65,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/sipintar/sipintar.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _TypingIndicator(avatar: _siPintarAvatar());
                }
                final msg = _messages[index];
                return msg.isUser
                    ? _UserBubble(message: msg, userInitial: _userInitial)
                    : _SiPintarBubble(
                        message: msg,
                        avatar: _siPintarAvatar(),
                        categoryOrder: _categoryOrder,
                        categoryPercentages: _categoryPercentages,
                        categoryEnabled: _categoryEnabled,
                        onPercentageChanged: (cat, val) => _updatePercentage(cat, val),
                        onEnabledChanged: (cat, val) =>
                            setState(() => _categoryEnabled[cat] = val),
                        onSimpan: _onSimpanPengaturan,
                        onTambahKategori: _onTambahKategori,
                      );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: Color(0xFF1D4ED8), size: 26),
                    onPressed: _onTakePhoto,
                  ),
                  IconButton(
                    icon: const Icon(Icons.image_outlined,
                        color: Color(0xFF1D4ED8), size: 24),
                    onPressed: _onPickGallery,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _inputController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _onSendText(),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                              color: Color(0xFF9CA3AF), fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _onSendText,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1D4ED8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Si Pintar bubble ──
class _SiPintarBubble extends StatelessWidget {
  final _ChatMessage message;
  final Widget avatar;
  final List<String> categoryOrder;
  final Map<String, double> categoryPercentages;
  final Map<String, bool> categoryEnabled;
  final Function(String, double) onPercentageChanged;
  final Function(String, bool) onEnabledChanged;
  final VoidCallback onSimpan;
  final VoidCallback onTambahKategori;

  const _SiPintarBubble({
    required this.message,
    required this.avatar,
    required this.categoryOrder,
    required this.categoryPercentages,
    required this.categoryEnabled,
    required this.onPercentageChanged,
    required this.onEnabledChanged,
    required this.onSimpan,
    required this.onTambahKategori,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 2),
            child: avatar,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Si Pintar',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151))),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 184, 229, 255),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Text(message.text,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 28, 33, 41),
                          height: 1.5)),
                ),
                if (message.showPreferences) ...[
                  const SizedBox(height: 8),
                  _PreferencesCard(
                    categoryOrder: categoryOrder,
                    categoryPercentages: categoryPercentages,
                    categoryEnabled: categoryEnabled,
                    onPercentageChanged: onPercentageChanged,
                    onEnabledChanged: onEnabledChanged,
                    onSimpan: onSimpan,
                    onTambahKategori: onTambahKategori,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Preferences card ──
class _PreferencesCard extends StatelessWidget {
  final List<String> categoryOrder;
  final Map<String, double> categoryPercentages;
  final Map<String, bool> categoryEnabled;
  final Function(String, double) onPercentageChanged;
  final Function(String, bool) onEnabledChanged;
  final VoidCallback onSimpan;
  final VoidCallback onTambahKategori;

  const _PreferencesCard({
    required this.categoryOrder,
    required this.categoryPercentages,
    required this.categoryEnabled,
    required this.onPercentageChanged,
    required this.onEnabledChanged,
    required this.onSimpan,
    required this.onTambahKategori,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.search, size: 45, color: Color(0xFF1D4ED8)),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Pilih Kategori yang Ingin Digunakan!',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text('(AI Rekomendasi)',
              style: TextStyle(
                  fontSize: 12,
                  color: Color.fromARGB(255, 48, 51, 58))),
          const SizedBox(height: 12),
          ...categoryOrder.map((cat) {
            final enabled = categoryEnabled[cat] ?? false;
            final pct = categoryPercentages[cat] ?? 0;
            return _CategoryRow(
              label: cat,
              percentage: pct,
              enabled: enabled,
              onToggle: (val) => onEnabledChanged(cat, val),
              onChanged: (val) => onPercentageChanged(cat, val),
            );
          }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTambahKategori,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1D4ED8),
                side: const BorderSide(color: Color(0xFF1D4ED8)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah Kategori Baru',
                  style: TextStyle(fontSize: 13)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSimpan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D4ED8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                elevation: 0,
              ),
              child: const Text('Simpan Pengaturan',
                  style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String label;
  final double percentage;
  final bool enabled;
  final Function(bool) onToggle;
  final Function(double) onChanged;

  const _CategoryRow({
    required this.label,
    required this.percentage,
    required this.enabled,
    required this.onToggle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: enabled,
              onChanged: (v) => onToggle(v ?? false),
              activeColor: const Color(0xFF1D4ED8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: enabled
                        ? const Color(0xFF111827)
                        : const Color(0xFF9CA3AF)),
                overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: enabled
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFFD1D5DB),
                inactiveTrackColor: const Color(0xFFE5E7EB),
                thumbColor: enabled
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFFD1D5DB),
              ),
              child: Slider(
                value: enabled ? percentage : 0,
                min: 0,
                max: 100,
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '${percentage.round()}%',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: enabled
                      ? const Color(0xFF1D4ED8)
                      : const Color(0xFF9CA3AF)),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ── User bubble ──
class _UserBubble extends StatelessWidget {
  final _ChatMessage message;
  final String userInitial; // ✅ FIX: passed in from state, not hardcoded

  const _UserBubble({required this.message, required this.userInitial});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: message.imagePath != null
                ? Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.6),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    // ✅ FIX: use Image.file() for local paths, not Image.network()
                    child: Image.file(
                      File(message.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 160,
                        height: 120,
                        color: const Color(0xFFE5E7EB),
                        child: const Icon(Icons.image_outlined,
                            color: Color(0xFF9CA3AF)),
                      ),
                    ),
                  )
                : Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D4ED8),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Text(message.text,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            height: 1.4)),
                  ),
          ),
          const SizedBox(width: 8),
          // ✅ FIX: shows real username initial from SharedPreferences
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
                color: Color(0xFFBFDBFE), shape: BoxShape.circle),
            child: Center(
              child: Text(
                userInitial,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D4ED8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Typing indicator ──
class _TypingIndicator extends StatefulWidget {
  final Widget avatar;
  const _TypingIndicator({required this.avatar});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
    _dotAnimations = List.generate(3, (i) {
      final start = i * 0.2;
      return Tween<double>(begin: 0, end: -6).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(start, start + 0.4, curve: Curves.easeInOut),
      ));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(right: 8, top: 2),
              child: widget.avatar),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2))
              ],
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (i) => Transform.translate(
                    offset: Offset(0, _dotAnimations[i].value),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Color(0xFF9CA3AF),
                          shape: BoxShape.circle),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool showPreferences;
  final String? imagePath;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.showPreferences = false,
    this.imagePath,
  });
}