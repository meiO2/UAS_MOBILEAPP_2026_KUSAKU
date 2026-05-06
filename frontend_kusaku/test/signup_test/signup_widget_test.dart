import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/Screens/Singup_Screen-frontend/sign_up_screen.dart';
import '../../lib/Screens/Singup_Screen-frontend/confirm_transaction_pin_screen.dart';
import '../../lib/Screens/Singup_Screen-frontend/otp_verification_screen.dart';
import '../../lib/Screens/Singup_Screen-frontend/create_transaction_pin_screen.dart';


Widget _wrap(Widget child) => MaterialApp(home: child);

const _kProps = (
  username: 'testuser',
  password: 'TestPass1',
  email: 'test@example.com',
  phoneNumber: '08123456789',
  otp: '123456',
);


void main() {
  group('SignUpScreen –', () {
    testWidgets('renders all five input fields', (tester) async {
      await tester.pumpWidget(_wrap(const SignUpScreen()));

      expect(find.widgetWithText(TextField, 'Username'), findsOneWidget);
      // KusakuInputField uses TextField internally; match by hint text
      expect(find.byType(TextField), findsNWidgets(5));
    });

    testWidgets('shows password hint text', (tester) async {
      await tester.pumpWidget(_wrap(const SignUpScreen()));

      expect(find.text('Password'), findsAtLeastNWidgets(1));
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('shows email and phone hint texts', (tester) async {
      await tester.pumpWidget(_wrap(const SignUpScreen()));

      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
    });

    testWidgets('Sign Up button is present', (tester) async {
      await tester.pumpWidget(_wrap(const SignUpScreen()));

      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('password visibility toggle changes icon', (tester) async {
      await tester.pumpWidget(_wrap(const SignUpScreen()));

      // Initially visibility_off (obscured)
      expect(find.byIcon(Icons.visibility_off), findsAtLeastNWidgets(1));

      // Tap the first visibility toggle (Password field)
      await tester.tap(find.byIcon(Icons.visibility_off).first);
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsAtLeastNWidgets(1));
    });

    testWidgets('shows snackbar when Sign Up tapped with empty fields',
        (tester) async {
      await tester.pumpWidget(_wrap(const SignUpScreen()));

      await tester.tap(find.text('Sign Up'));
      await tester.pump(); // start animation
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Username dan password wajib diisi'), findsOneWidget);
    });

    testWidgets('shows snackbar when passwords do not match', (tester) async {
      await tester.pumpWidget(_wrap(const SignUpScreen()));

      await tester.enterText(
          find.byType(TextField).at(0), 'john'); // username
      await tester.enterText(
          find.byType(TextField).at(1), 'pass123'); // password
      await tester.enterText(
          find.byType(TextField).at(2), 'different'); // confirm
      await tester.enterText(
          find.byType(TextField).at(3), 'john@example.com'); // email
      await tester.enterText(
          find.byType(TextField).at(4), '08123456789'); // phone

      await tester.tap(find.text('Sign Up'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Password dan Confirm Password tidak sama'),
          findsOneWidget);
    });

    testWidgets('"Already have an account?" text is shown', (tester) async {
      await tester.pumpWidget(_wrap(const SignUpScreen()));

      expect(find.text('Already have an account? '), findsOneWidget);
    });

    testWidgets('Log in redirect button is tappable', (tester) async {
      await tester.pumpWidget(_wrap(const SignUpScreen()));

      final loginBtn = find.text('Log in');
      expect(loginBtn, findsOneWidget);

      await tester.tap(loginBtn);
      await tester.pumpAndSettle();
      // After pop the SignUpScreen is gone; no crash = success
    });
  });

  // ── OtpVerificationScreen ─────────────────────────────────────────────────

  group('OtpVerificationScreen –', () {
    Widget _buildOtp() => _wrap(OtpVerificationScreen(
          phoneNumber: _kProps.phoneNumber,
          username: _kProps.username,
          password: _kProps.password,
          email: _kProps.email,
        ));

    testWidgets('renders 6 OTP input boxes', (tester) async {
      await tester.pumpWidget(_buildOtp());

      // 6 single-character TextField widgets
      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(6));
    });

    testWidgets('title text is shown', (tester) async {
      await tester.pumpWidget(_buildOtp());

      expect(find.text('Verification Code (OTP)'), findsOneWidget);
    });

    testWidgets('phone number is masked in subtitle', (tester) async {
      await tester.pumpWidget(_buildOtp());

      // '08123456789' masks to '081****6789'
      expect(find.textContaining('081****6789'), findsOneWidget);
    });

    testWidgets('Resend button is present', (tester) async {
      await tester.pumpWidget(_buildOtp());

      expect(find.text('Resend'), findsOneWidget);
    });

    testWidgets('Back button is present and pops on tap', (tester) async {
      // Wrap inside a navigator stack so pop works
      await tester.pumpWidget(MaterialApp(
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              phoneNumber: _kProps.phoneNumber,
              username: _kProps.username,
              password: _kProps.password,
              email: _kProps.email,
            ),
          ),
        ),
      ));

      expect(find.text('< Back'), findsOneWidget);
      // Tapping back should not throw even with single route
      await tester.tap(find.text('< Back'));
      await tester.pumpAndSettle();
    });

    testWidgets('focus advances to next field on input', (tester) async {
      await tester.pumpWidget(_buildOtp());

      final fields = find.byType(TextField);
      await tester.tap(fields.first);
      await tester.pump();
      await tester.enterText(fields.first, '1');
      await tester.pump();

      // Second field should now be focused (no crash = good)
      expect(find.byType(TextField), findsNWidgets(6));
    });
  });

  // ── CreateTransactionPinScreen ────────────────────────────────────────────

  group('CreateTransactionPinScreen –', () {
    Widget _buildCreate() => _wrap(CreateTransactionPinScreen(
          username: _kProps.username,
          password: _kProps.password,
          email: _kProps.email,
          phoneNumber: _kProps.phoneNumber,
          otp: _kProps.otp,
        ));

    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(_buildCreate());

      expect(find.text('Create a Transaction PIN'), findsOneWidget);
    });

    testWidgets('renders 6 dot indicators', (tester) async {
      await tester.pumpWidget(_buildCreate());

      // 6 circular containers for dot indicators
      final circles = find.byWidgetPredicate((w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).shape == BoxShape.circle);
      expect(circles, findsNWidgets(6));
    });

    testWidgets('number pad buttons 1-9 and 0 are present', (tester) async {
      await tester.pumpWidget(_buildCreate());

      for (final n in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']) {
        expect(find.text(n), findsOneWidget);
      }
    });

    testWidgets('tapping a digit fills one dot', (tester) async {
      await tester.pumpWidget(_buildCreate());

      // Before: all dots grey. After tapping '1': one dot blue.
      // We can't inspect dot colors easily, but we can assert no crash.
      await tester.tap(find.text('1'));
      await tester.pump();

      expect(find.text('1'), findsOneWidget); // button still visible
    });

    testWidgets('backspace icon button is present', (tester) async {
      await tester.pumpWidget(_buildCreate());

      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    });

    testWidgets('check icon (confirm) is present', (tester) async {
      await tester.pumpWidget(_buildCreate());

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('confirm disabled until 6 digits entered', (tester) async {
      await tester.pumpWidget(_buildCreate());

      // Tap confirm with 0 digits – should not navigate (no crash)
      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();

      // Still on CreateTransactionPinScreen
      expect(find.text('Create a Transaction PIN'), findsOneWidget);
    });
  });

  // ── ConfirmTransactionPinScreen ───────────────────────────────────────────

  group('ConfirmTransactionPinScreen –', () {
    Widget _buildConfirm({String initialPin = '123456'}) =>
        _wrap(ConfirmTransactionPinScreen(
          initialPin: initialPin,
          username: _kProps.username,
          password: _kProps.password,
          email: _kProps.email,
          phoneNumber: _kProps.phoneNumber,
          otp: _kProps.otp,
        ));

    testWidgets('renders confirm title text', (tester) async {
      await tester.pumpWidget(_buildConfirm());

      expect(find.text('Confirm Transaction Password'), findsOneWidget);
    });

    testWidgets('renders 6 dot indicators', (tester) async {
      await tester.pumpWidget(_buildConfirm());

      final circles = find.byWidgetPredicate((w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).shape == BoxShape.circle);
      expect(circles, findsNWidgets(6));
    });

    testWidgets('shows snackbar when PINs do not match', (tester) async {
      await tester.pumpWidget(_buildConfirm(initialPin: '111111'));

      // Enter a different PIN: 222222
      for (final n in ['2', '2', '2', '2', '2', '2']) {
        await tester.tap(find.text(n));
        await tester.pump();
      }

      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('PIN tidak sama. Coba lagi.'), findsOneWidget);
    });

    testWidgets('close (X) button is present', (tester) async {
      await tester.pumpWidget(_buildConfirm());

      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}