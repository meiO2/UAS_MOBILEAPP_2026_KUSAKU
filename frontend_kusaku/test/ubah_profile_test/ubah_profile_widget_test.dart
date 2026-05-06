import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_kusaku/Navigation/ProfilePage_Kusaku/ubah_profile_page.dart';

void main() {
  Widget buildTest() {
    return MaterialApp(
      home: UbahProfilePage(
        mockLoader: () async => {
          'username': 'Budi',
          'phone_number': '08123',
          'email': 'budi@mail.com',
        },
      ),
    );
  }

  testWidgets('shows loaded data', (tester) async {
    await tester.pumpWidget(buildTest());
    await tester.pumpAndSettle();

    expect(find.text('Budi'), findsOneWidget);
    expect(find.text('08123'), findsOneWidget);
    expect(find.text('budi@mail.com'), findsOneWidget);
  });

  testWidgets('opens dialog when tapping Ubah Nomor', (tester) async {
    await tester.pumpWidget(buildTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ubah').first);
    await tester.pumpAndSettle();

    expect(find.text('Yakin mau ubah nomor HP?'), findsOneWidget);
  });

  testWidgets('closes dialog when cancel pressed', (tester) async {
    await tester.pumpWidget(buildTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ubah').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ga jadi deh'));
    await tester.pumpAndSettle();

    expect(find.text('Yakin mau ubah nomor HP?'), findsNothing);
  });

  testWidgets('shows loading initially', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: UbahProfilePage()),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}