import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend_kusaku/Navigation/ProfilePage_Kusaku/ubah_profile_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const mockUsername    = 'Leon';
  const mockPhone       = '08123456789';
  const mockEmail       = 'leon@test.com';
  const updatedUsername = 'Leon Updated';

  Future<void> pumpPage(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'user_id': 1});

    await tester.pumpWidget(
      MaterialApp(
        home: UbahProfilePage(
          mockLoader: () async => {
            'username':     mockUsername,
            'phone_number': mockPhone,
            'email':         mockEmail,
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('shows profile data after load', (tester) async {
    await pumpPage(tester);

    expect(find.text(mockUsername), findsOneWidget);
    expect(find.text(mockPhone),    findsOneWidget);
    expect(find.text(mockEmail),    findsOneWidget);
  });

  testWidgets('can edit nama lengkap field', (tester) async {
    await pumpPage(tester);

    final nameField = find.byKey(const Key('namaLengkapField'));
    expect(nameField, findsOneWidget);

    await tester.tap(nameField);
    await tester.pumpAndSettle();

    await tester.enterText(nameField, updatedUsername);
    await tester.pump();

    expect(find.text(updatedUsername), findsOneWidget);
  });

  testWidgets('ubah nomor dialog opens and can be cancelled', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byKey(const Key('ubahNomorButton')));
    await tester.pumpAndSettle();

    expect(find.text('Yakin mau ubah nomor HP?'), findsOneWidget);

    await tester.tap(find.text('Ga jadi deh'));
    await tester.pumpAndSettle();

    expect(find.text('Yakin mau ubah nomor HP?'), findsNothing);
  });

  testWidgets('ubah nomor confirm navigates to UbahNomorPage', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byKey(const Key('ubahNomorButton')));
    await tester.pumpAndSettle();

    expect(find.text('Yakin mau ubah nomor HP?'), findsOneWidget);

    await tester.tap(find.text('Ya, ubah'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Ubah Profile'), findsNothing);
  });

  testWidgets('full flow passes', (tester) async {
    await pumpPage(tester);

    expect(find.text(mockUsername), findsOneWidget);
    expect(find.text(mockPhone),    findsOneWidget);
    expect(find.text(mockEmail),    findsOneWidget);

    // ── Edit name ──
    final nameField = find.byKey(const Key('namaLengkapField'));
    await tester.tap(nameField);
    await tester.pumpAndSettle();
    await tester.enterText(nameField, updatedUsername);
    await tester.pump();
    expect(find.text(updatedUsername), findsOneWidget);

    // ── Open Ubah Nomor dialog ──
    final ubahNomorBtn = find.byKey(const Key('ubahNomorButton'));
    await tester.tap(ubahNomorBtn);
    await tester.pumpAndSettle();
    expect(find.text('Yakin mau ubah nomor HP?'), findsOneWidget);

    // ── Cancel ──
    await tester.tap(find.text('Ga jadi deh'));
    await tester.pumpAndSettle();
    expect(find.text('Yakin mau ubah nomor HP?'), findsNothing);

    // ── Open again then confirm ──
    await tester.tap(ubahNomorBtn);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ya, ubah'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify navigation occurred
    expect(find.text('Ubah Profile'), findsNothing);

    // ── Navigate back manually ──
    // We use Navigator.pop directly on the build context of the current widget 
    // to avoid the "Back Button Not Found" error.
    final BuildContext context = tester.element(find.byType(Navigator));
    Navigator.pop(context);
    await tester.pumpAndSettle();

    expect(find.text('Ubah Profile'), findsOneWidget);
  });
}