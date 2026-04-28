import 'package:flutter/material.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/topup_pulsa_page.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/topup_store_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  int? _userId;
  String _kodeKusaku = '-';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id');
      _kodeKusaku = prefs.getString('phone_number') ?? '-';
    });
  }

  void _navigate(Widget page) {
    if (_userId == null) return; // not loaded yet, do nothing
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title: const Text('Top Up',
            style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Kode Kusaku: $_kodeKusaku',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: 35, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1D4ED8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _userId == null
                  // Show loading spinner while user data loads
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _TopUpMethod(
                          imagePath: 'assets/images/topup/phone.png',
                          label: 'Pulsa',
                          onTap: () => _navigate(const TopUpPulsaPage()),
                        ),
                        _TopUpMethod(
                          imagePath: 'assets/images/topup/alfamart.png',
                          label: 'Alfamart',
                          onTap: () => _navigate(
                              TopUpStorePage(storeName: 'Alfamart', userId: _userId!)),
                        ),
                        _TopUpMethod(
                          imagePath: 'assets/images/topup/indomaret.png',
                          label: 'Indomaret',
                          onTap: () => _navigate(
                              TopUpStorePage(storeName: 'Indomaret', userId: _userId!)),
                        ),
                        _TopUpMethod(
                          imagePath: 'assets/images/topup/lawson.png',
                          label: 'Lawson',
                          onTap: () => _navigate(
                              TopUpStorePage(storeName: 'Lawson', userId: _userId!)),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopUpMethod extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;

  const _TopUpMethod(
      {required this.imagePath,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.storefront_outlined,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}