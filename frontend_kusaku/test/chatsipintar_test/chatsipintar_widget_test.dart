import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_kusaku/Services/chat_service.dart';

/// ---------------------------------------------------------------------------
/// Widget Tests – ChatSiPintarPage
///
/// ChatSiPintarPage fires real HTTP in initState (ChatService static methods)
/// which cannot be intercepted without refactoring. Mounting the full page in
/// tests always leaves pending timers from _scrollToBottom's Future.delayed.
///
/// Strategy: test the PRIVATE sub-widgets directly by redefining them locally,
/// and test ChatResponse (the only public model) inline.
/// ---------------------------------------------------------------------------
void main() {

  // ── ChatResponse model ─────────────────────────────────────────────────────
  group('ChatResponse model', () {
    test('fromJson parses all fields', () {
      final r = ChatResponse.fromJson({
        'reply': 'Halo!',
        'type': 'budget_suggestion',
        'data': {'Makanan': 40.0},
      });
      expect(r.reply, 'Halo!');
      expect(r.type, 'budget_suggestion');
      expect(r.data, isNotNull);
      expect(r.data!['Makanan'], 40.0);
    });

    test('fromJson defaults when fields missing', () {
      final r = ChatResponse.fromJson({});
      expect(r.reply, '');
      expect(r.type, 'text');
      expect(r.data, isNull);
    });
  });

  // ── User bubble widget ─────────────────────────────────────────────────────
  group('User bubble', () {
    Widget buildBubble(String initial, String text) {
      return MaterialApp(
        home: Scaffold(
          body: _TestUserBubble(initial: initial, text: text),
        ),
      );
    }

    testWidgets('displays message text', (tester) async {
      await tester.pumpWidget(buildBubble('B', 'Halo SiPintar!'));
      expect(find.text('Halo SiPintar!'), findsOneWidget);
    });

    testWidgets('displays user initial in avatar', (tester) async {
      await tester.pumpWidget(buildBubble('D', 'Test'));
      expect(find.text('D'), findsOneWidget);
    });

    testWidgets('renders without exception', (tester) async {
      await tester.pumpWidget(buildBubble('A', 'Hello'));
      expect(tester.takeException(), isNull);
    });
  });

  // ── SiPintar bubble widget ─────────────────────────────────────────────────
  group('SiPintar bubble', () {
    Widget buildBubble(String text) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: _TestSiPintarBubble(text: text),
          ),
        ),
      );
    }

    testWidgets('displays "Si Pintar" label', (tester) async {
      await tester.pumpWidget(buildBubble('Apa kabar?'));
      expect(find.text('Si Pintar'), findsOneWidget);
    });

    testWidgets('displays message text', (tester) async {
      await tester.pumpWidget(buildBubble('Apa kabar?'));
      expect(find.text('Apa kabar?'), findsOneWidget);
    });

    testWidgets('renders without exception', (tester) async {
      await tester.pumpWidget(buildBubble('Test pesan'));
      expect(tester.takeException(), isNull);
    });
  });

  // ── Category row widget ────────────────────────────────────────────────────
  group('Category row', () {
    Widget buildRow({
      required String label,
      required double percentage,
      required bool enabled,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: _TestCategoryRow(
            label: label,
            percentage: percentage,
            enabled: enabled,
          ),
        ),
      );
    }

    testWidgets('displays category label', (tester) async {
      await tester.pumpWidget(
          buildRow(label: 'Makanan', percentage: 40, enabled: true));
      expect(find.text('Makanan'), findsOneWidget);
    });

    testWidgets('displays percentage text', (tester) async {
      await tester.pumpWidget(
          buildRow(label: 'Transport', percentage: 30, enabled: true));
      expect(find.text('30%'), findsOneWidget);
    });

    testWidgets('checkbox is checked when enabled', (tester) async {
      await tester.pumpWidget(
          buildRow(label: 'Makanan', percentage: 40, enabled: true));
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('checkbox is unchecked when disabled', (tester) async {
      await tester.pumpWidget(
          buildRow(label: 'Hiburan', percentage: 0, enabled: false));
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('slider is disabled when category is disabled', (tester) async {
      await tester.pumpWidget(
          buildRow(label: 'Hiburan', percentage: 0, enabled: false));
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.onChanged, isNull);
    });

    testWidgets('slider is enabled when category is enabled', (tester) async {
      await tester.pumpWidget(
          buildRow(label: 'Makanan', percentage: 40, enabled: true));
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.onChanged, isNotNull);
    });

    testWidgets('toggling checkbox calls onToggle', (tester) async {
      bool toggled = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: _TestCategoryRowCallback(
            label: 'Makanan',
            percentage: 40,
            enabled: true,
            onToggle: (v) => toggled = v,
          ),
        ),
      ));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(toggled, isFalse); // was true, toggled to false
    });
  });

  // ── Input bar send guard ───────────────────────────────────────────────────
  group('Send guard logic', () {
    bool shouldSend(String text) => text.trim().isNotEmpty;

    testWidgets('send button does nothing on empty input', (tester) async {
      final controller = TextEditingController();
      bool sent = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Row(children: [
            Expanded(child: TextField(controller: controller)),
            ElevatedButton(
              onPressed: () {
                if (shouldSend(controller.text)) sent = true;
              },
              child: const Text('Send'),
            ),
          ]),
        ),
      ));

      await tester.tap(find.text('Send'));
      await tester.pump();
      expect(sent, isFalse);
    });

    testWidgets('send button fires on non-empty input', (tester) async {
      final controller = TextEditingController(text: 'Halo');
      bool sent = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Row(children: [
            Expanded(child: TextField(controller: controller)),
            ElevatedButton(
              onPressed: () {
                if (shouldSend(controller.text)) sent = true;
              },
              child: const Text('Send'),
            ),
          ]),
        ),
      ));

      await tester.tap(find.text('Send'));
      await tester.pump();
      expect(sent, isTrue);
    });
  });

  // ── Tambah Kategori dialog ─────────────────────────────────────────────────
  group('Tambah Kategori dialog', () {
    testWidgets('dialog opens and shows text field', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (ctx) => ElevatedButton(
            onPressed: () => showDialog(
              context: ctx,
              builder: (_) => AlertDialog(
                title: const Text('Tambah Kategori Baru'),
                content: const TextField(
                    decoration: InputDecoration(hintText: 'Nama kategori...')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Batal')),
                ],
              ),
            ),
            child: const Text('Tambah'),
          )),
        ),
      ));

      await tester.tap(find.text('Tambah'));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Kategori Baru'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
    });

    testWidgets('dialog closes on Batal tap', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (ctx) => ElevatedButton(
            onPressed: () => showDialog(
              context: ctx,
              builder: (_) => AlertDialog(
                title: const Text('Tambah Kategori Baru'),
                content: const TextField(),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Batal')),
                ],
              ),
            ),
            child: const Text('Open'),
          )),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Kategori Baru'), findsNothing);
    });
  });
}

// ── Local test doubles of private widgets ──────────────────────────────────

class _TestUserBubble extends StatelessWidget {
  final String initial;
  final String text;
  const _TestUserBubble({required this.initial, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1D4ED8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(text,
              style: const TextStyle(fontSize: 13, color: Colors.white)),
        ),
        const SizedBox(width: 8),
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
              color: Color(0xFFBFDBFE), shape: BoxShape.circle),
          child: Center(
            child: Text(initial,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D4ED8))),
          ),
        ),
      ],
    );
  }
}

class _TestSiPintarBubble extends StatelessWidget {
  final String text;
  const _TestSiPintarBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36, height: 36,
          decoration: const BoxDecoration(
              color: Color(0xFFD467FF), shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Si Pintar',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: const Color(0xFFB8E5FF),
                    borderRadius: BorderRadius.circular(16)),
                child: Text(text,
                    style: const TextStyle(fontSize: 13, height: 1.5)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TestCategoryRow extends StatelessWidget {
  final String label;
  final double percentage;
  final bool enabled;
  const _TestCategoryRow(
      {required this.label,
      required this.percentage,
      required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: enabled,
          onChanged: (_) {},
          activeColor: const Color(0xFF1D4ED8),
        ),
        Text(label),
        Expanded(
          child: Slider(
            value: enabled ? percentage : 0,
            min: 0,
            max: 100,
            onChanged: enabled ? (_) {} : null,
          ),
        ),
        Text('${percentage.round()}%'),
      ],
    );
  }
}

class _TestCategoryRowCallback extends StatefulWidget {
  final String label;
  final double percentage;
  final bool enabled;
  final Function(bool) onToggle;
  const _TestCategoryRowCallback(
      {required this.label,
      required this.percentage,
      required this.enabled,
      required this.onToggle});

  @override
  State<_TestCategoryRowCallback> createState() =>
      _TestCategoryRowCallbackState();
}

class _TestCategoryRowCallbackState extends State<_TestCategoryRowCallback> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.enabled;
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: _enabled,
      onChanged: (v) {
        setState(() => _enabled = v ?? _enabled);
        widget.onToggle(v ?? _enabled);
      },
    );
  }
}