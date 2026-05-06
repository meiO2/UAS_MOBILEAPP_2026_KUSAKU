import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_kusaku/Navigation/Finance_Kusaku/chat_si_pintar_page.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // ✅ Use a real int value, or omit 'user_id' entirely
    SharedPreferences.setMockInitialValues({
      'user_id': 77,
      'username': 'TestUser',
    });
  });

  Widget buildApp() {
    return const MaterialApp(
      home: ChatSiPintarPage(),
    );
  }

  group('ChatSiPintarPage Safe Tests (No HTTP)', () {

    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3)); // let async _loadUser finish

      expect(find.byType(ChatSiPintarPage), findsOneWidget);
    });

    testWidgets('does not throw exception on startup', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3)); // let async _init finish

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders MaterialApp properly', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));

      expect(find.byType(MaterialApp), findsOneWidget);
    });

  });
}