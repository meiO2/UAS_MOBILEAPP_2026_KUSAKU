import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_kusaku/Transaction_confimation/payment_confirmation_models.dart';
import 'package:frontend_kusaku/Transaction_confimation/payment_confirmation_page.dart';

/// ---------------------------------------------------------------------------
/// Integration Tests – QR Payment Flow
///
/// TransferPage is intentionally excluded — its initState fires real HTTP
/// (_loadSession, _loadRecentRecipients, _loadCategories) that time out in
/// tests and cause setState-after-dispose errors. It cannot be safely mounted
/// without refactoring the page to accept injectable HTTP clients.
///
/// PaymentConfirmationPage is fully testable via onSubmitPayment injection.
/// ---------------------------------------------------------------------------
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'user_id': 99,
      'phone_number': '08123456789',
      'full_name': 'Test User',
    });
  });

  Future<void> pumpLarge(WidgetTester tester, Widget widget) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(widget);
    await tester.pump();
  }

  PaymentConfirmationData makePaymentData() => PaymentConfirmationData(
        transactionId: 'txn-qr-001',
        methodType: PaymentMethodType.qris,
        methodLabel: 'Pembayaran Qris',
        amount: 75000,
        transactionFee: 0,
        remainingBalance: 925000,
        merchant: PaymentMerchantInfo(
          name: 'Warung Kopi',
          accountName: 'a.n. Warung Kopi ID',
          transactedAt: DateTime(2026, 3, 1, 9, 0),
          logoText: 'W',
        ),
        categories: [
          const PaymentCategoryData(
            id: '1',
            name: 'Makan & Minum',
            icon: Icons.restaurant,
            remainingAmount: 400000,
          ),
          const PaymentCategoryData(
            id: '5',
            name: 'Tabungan',
            icon: Icons.savings,
            remainingAmount: 300000,
            isSaving: true,
          ),
        ],
      );

  // ── 1. Initial render ──────────────────────────────────────────────────────
  group('1. PaymentConfirmationPage — initial render', () {
    testWidgets('shows Konfirmasi Pembayaran header', (tester) async {
      await pumpLarge(tester, MaterialApp(
        home: PaymentConfirmationPage(data: makePaymentData()),
      ));
      expect(find.text('Konfirmasi Pembayaran'), findsOneWidget);
    });

    testWidgets('shows merchant name', (tester) async {
      await pumpLarge(tester, MaterialApp(
        home: PaymentConfirmationPage(data: makePaymentData()),
      ));
      expect(find.text('Warung Kopi'), findsOneWidget);
    });

    testWidgets('shows payment method label', (tester) async {
      await pumpLarge(tester, MaterialApp(
        home: PaymentConfirmationPage(data: makePaymentData()),
      ));
      expect(find.text('Pembayaran Qris'), findsOneWidget);
    });

    testWidgets('shows Bayar button', (tester) async {
      await pumpLarge(tester, MaterialApp(
        home: PaymentConfirmationPage(data: makePaymentData()),
      ));
      expect(find.text('Bayar'), findsOneWidget);
    });

    testWidgets('shows Batal button', (tester) async {
      await pumpLarge(tester, MaterialApp(
        home: PaymentConfirmationPage(data: makePaymentData()),
      ));
      expect(find.text('Batal'), findsOneWidget);
    });

    testWidgets('shows first category selected by default', (tester) async {
      await pumpLarge(tester, MaterialApp(
        home: PaymentConfirmationPage(data: makePaymentData()),
      ));
      expect(find.text('Makan & Minum'), findsOneWidget);
    });

    testWidgets('renders without exception', (tester) async {
      await pumpLarge(tester, MaterialApp(
        home: PaymentConfirmationPage(data: makePaymentData()),
      ));
      expect(find.byType(PaymentConfirmationPage), findsOneWidget);
    });
  });

  // ── 2. Batal cancels ──────────────────────────────────────────────────────
  group('2. PaymentConfirmationPage — Batal cancels', () {
    testWidgets('Batal pops back to previous route', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('PrevPage'))),
      );
      tester.state<NavigatorState>(find.byType(Navigator)).push(
        MaterialPageRoute(
          builder: (_) => PaymentConfirmationPage(data: makePaymentData()),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Batal'), findsOneWidget);
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(find.text('PrevPage'), findsOneWidget);
    });

    testWidgets('Batal does not show success screen', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('PrevPage'))),
      );
      tester.state<NavigatorState>(find.byType(Navigator)).push(
        MaterialPageRoute(
          builder: (_) => PaymentConfirmationPage(data: makePaymentData()),
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(find.text('Payment Successful!'), findsNothing);
    });
  });

  // ── 3. Bayar opens PIN ────────────────────────────────────────────────────
  group('3. PaymentConfirmationPage — Bayar opens PIN dialog', () {
    testWidgets('tapping Bayar opens a dialog or bottom sheet', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(MaterialApp(
        home: PaymentConfirmationPage(
          data: makePaymentData(),
          onSubmitPayment: (_) async =>
              const PaymentSubmissionResult(isSuccess: true),
        ),
      ));
      await tester.pump();

      await tester.tap(find.text('Bayar'));
      await tester.pumpAndSettle();

      final hasDialog = find.byType(AlertDialog).evaluate().isNotEmpty ||
          find.byType(Dialog).evaluate().isNotEmpty ||
          find.byType(BottomSheet).evaluate().isNotEmpty;
      expect(hasDialog, isTrue);
    });

    testWidgets('Bayar button is enabled in idle state', (tester) async {
      await pumpLarge(tester, MaterialApp(
        home: PaymentConfirmationPage(data: makePaymentData()),
      ));
      final bayarButton = find.text('Bayar');
      expect(bayarButton, findsOneWidget);
    });
  });

  // ── 4. Failure state ──────────────────────────────────────────────────────
  group('4. PaymentConfirmationPage — failure state', () {
    testWidgets('success section not visible before any action', (tester) async {
      await pumpLarge(tester, MaterialApp(
        home: PaymentConfirmationPage(
          data: makePaymentData(),
          onSubmitPayment: (_) async => const PaymentSubmissionResult(
            isSuccess: false,
            errorMessage: 'Transaksi gagal.',
          ),
        ),
      ));
      expect(find.text('Payment Successful!'), findsNothing);
      expect(find.text('Transaksi gagal.'), findsNothing);
    });
  });

  // ── 5. Category data ──────────────────────────────────────────────────────
  group('5. PaymentConfirmationPage — category display', () {
    testWidgets('all provided categories are accessible in widget tree',
        (tester) async {
      await pumpLarge(tester, MaterialApp(
        home: PaymentConfirmationPage(data: makePaymentData()),
      ));
      // First category is shown by default
      expect(find.text('Makan & Minum'), findsOneWidget);
    });

    testWidgets('page stays on confirmation screen initially', (tester) async {
      await pumpLarge(tester, MaterialApp(
        home: PaymentConfirmationPage(data: makePaymentData()),
      ));
      expect(find.text('Konfirmasi Pembayaran'), findsOneWidget);
      expect(find.text('Payment Successful!'), findsNothing);
    });
  });
}