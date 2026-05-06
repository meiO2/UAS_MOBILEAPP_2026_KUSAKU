import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend_kusaku/Navigation/ProfilePage_Kusaku/ubah_profile_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('UbahProfilePage full flow (mocked, no API)', (tester) async {
  SharedPreferences.setMockInitialValues({
    'user_id': 1,
  });

  await tester.pumpWidget(
    MaterialApp(
      home: UbahProfilePage(
        mockLoader: () async => {
          'username': 'Leon',
          'phone_number': '08123456789',
          'email': 'leon@test.com',
        },
      ),
    ),
  );

  await tester.pumpAndSettle();

  // ✅ Initial data
  expect(find.text('Leon'), findsOneWidget);
  expect(find.text('08123456789'), findsOneWidget);
  expect(find.text('leon@test.com'), findsOneWidget);

  // ✏️ Edit name
  final nameField = find.descendant(
    of: find.text('Nama Lengkap'),
    matching: find.byType(TextField),
  );

  await tester.tap(nameField);
  await tester.enterText(nameField, 'Leon Updated');
  await tester.pump();

  expect(find.text('Leon Updated'), findsOneWidget);

  // 📱 Open "Ubah Nomor"
  final ubahNomorButton = find.descendant(
    of: find.text('Nomor HP'),
    matching: find.text('Ubah'),
  );

  await tester.tap(ubahNomorButton);
  await tester.pumpAndSettle();

  expect(find.text('Yakin mau ubah nomor HP?'), findsOneWidget);

  // Cancel
  await tester.tap(find.text('Ga jadi deh'));
  await tester.pumpAndSettle();
  expect(find.text('Yakin mau ubah nomor HP?'), findsNothing);

  // Open again
  await tester.tap(ubahNomorButton);
  await tester.pumpAndSettle();

  // Confirm
  await tester.tap(find.text('Ya, ubah'));
  await tester.pumpAndSettle(const Duration(seconds: 1));

  // 🔥 Better assertion (adjust if needed)
  expect(find.text('Ubah Profile'), findsNothing);

  // 🔙 Go back
  await tester.pageBack();
  await tester.pumpAndSettle();

  expect(find.text('Ubah Profile'), findsOneWidget);
});
}