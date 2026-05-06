import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../lib/Screens/Singup_Screen-frontend/sign_up_screen.dart';
import '../lib/Screens/Singup_Screen-frontend/confirm_transaction_pin_screen.dart';
import '../lib/Screens/Singup_Screen-frontend/otp_verification_screen.dart';
import '../lib/Screens/Singup_Screen-frontend/create_transaction_pin_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const kUsername = 'integrationuser';
  const kPassword = 'IntPass123!';
  const kEmail    = 'integration@example.com';
  const kPhone    = '08112345678';
  const kOtp      = '000000';
  const kPin      = '123456';

  Widget buildSignUp() => const MaterialApp(home: SignUpScreen());

  Widget buildOtp() => const MaterialApp(
        home: OtpVerificationScreen(
          phoneNumber: kPhone,
          username: kUsername,
          password: kPassword,
          email: kEmail,
        ),
      );

  Widget buildCreate() => const MaterialApp(
        home: CreateTransactionPinScreen(
          username: kUsername,
          password: kPassword,
          email: kEmail,
          phoneNumber: kPhone,
          otp: kOtp,
        ),
      );

  Widget buildConfirm({String initialPin = kPin}) => MaterialApp(
        home: ConfirmTransactionPinScreen(
          initialPin: initialPin,
          username: kUsername,
          password: kPassword,
          email: kEmail,
          phoneNumber: kPhone,
          otp: kOtp,
        ),
      );

  Future<void> tapSignUpAndWait(WidgetTester tester) async {
    await tester.tap(find.text('Sign Up'));
    await tester.pump();                                   // setState
    await tester.pump(const Duration(milliseconds: 600)); // snackbar animation
  }

  /// Enters each digit of [pin] on a pin-pad screen.
  Future<void> enterPin(WidgetTester tester, String pin) async {
    for (final digit in pin.split('')) {
      await tester.tap(find.text(digit).first);
      await tester.pump(const Duration(milliseconds: 80));
    }
  }

  group('[Integration] SignUpScreen – validation', () {
    testWidgets('empty form shows required-field snackbar', (tester) async {
      await tester.pumpWidget(buildSignUp());
      await tester.pumpAndSettle();

      await tapSignUpAndWait(tester);

      expect(find.text('Username dan password wajib diisi'), findsOneWidget);
    });

    testWidgets('only username filled still shows required-field snackbar',
        (tester) async {
      await tester.pumpWidget(buildSignUp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'john');
      await tapSignUpAndWait(tester);

      expect(find.text('Username dan password wajib diisi'), findsOneWidget);
    });

    testWidgets('mismatched passwords shows mismatch snackbar', (tester) async {
      await tester.pumpWidget(buildSignUp());
      await tester.pumpAndSettle();

      final f = find.byType(TextField);
      await tester.enterText(f.at(0), 'john');
      await tester.enterText(f.at(1), 'Password1');
      await tester.enterText(f.at(2), 'Different1'); // ≠ password
      await tester.enterText(f.at(3), 'j@mail.com');
      await tester.enterText(f.at(4), '08111111111');
      await tapSignUpAndWait(tester);

      expect(
        find.text('Password dan Confirm Password tidak sama'),
        findsOneWidget,
      );
    });

    testWidgets('missing phone shows phone-required snackbar', (tester) async {
      await tester.pumpWidget(buildSignUp());
      await tester.pumpAndSettle();

      final f = find.byType(TextField);
      await tester.enterText(f.at(0), 'john');
      await tester.enterText(f.at(1), 'Password2');
      await tester.enterText(f.at(2), 'Password2');
      await tester.enterText(f.at(3), 'j@mail.com');
      // phone (index 4) left empty intentionally
      await tapSignUpAndWait(tester);

      expect(find.text('Phone Number wajib diisi'), findsOneWidget);
    });

    testWidgets('missing email shows email-required snackbar', (tester) async {
      await tester.pumpWidget(buildSignUp());
      await tester.pumpAndSettle();

      final f = find.byType(TextField);
      await tester.enterText(f.at(0), 'john');
      await tester.enterText(f.at(1), 'Password3');
      await tester.enterText(f.at(2), 'Password3');
      // email (index 3) left empty intentionally
      await tester.enterText(f.at(4), '08199999999');
      await tapSignUpAndWait(tester);

      expect(find.text('Email wajib diisi'), findsOneWidget);
    });
  });


  group('[Integration] SignUpScreen – UI interactions', () {
    testWidgets('all five input fields are rendered', (tester) async {
      await tester.pumpWidget(buildSignUp());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(5));
    });

    testWidgets('password visibility toggles icon for Password field',
        (tester) async {
      await tester.pumpWidget(buildSignUp());
      await tester.pumpAndSettle();

      // Both start hidden
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));

      // Toggle first field (Password)
      await tester.tap(find.byIcon(Icons.visibility_off).first);
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('password visibility toggles icon for Confirm Password field',
        (tester) async {
      await tester.pumpWidget(buildSignUp());
      await tester.pumpAndSettle();

      // Toggle both fields
      await tester.tap(find.byIcon(Icons.visibility_off).first);
      await tester.pump();
      await tester.tap(find.byIcon(Icons.visibility_off).first);
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsNWidgets(2));
    });

    testWidgets('"Already have an account?" text is visible', (tester) async {
      await tester.pumpWidget(buildSignUp());
      await tester.pumpAndSettle();

      expect(find.text('Already have an account? '), findsOneWidget);
    });

    testWidgets('Log in button pops screen', (tester) async {
      // Push SignUpScreen so pop() has somewhere to return to.
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const SignUpScreen()),
            ),
            child: const Text('Go'),
          );
        }),
      ));

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('Log in'), findsOneWidget);
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      // SignUpScreen is popped — its content is gone
      expect(find.text('Sign Up'), findsNothing);
    });
  });

  group('[Integration] OtpVerificationScreen – UI', () {
    testWidgets('renders 6 OTP input boxes', (tester) async {
      await tester.pumpWidget(buildOtp());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(6));
    });

    testWidgets('title text is visible', (tester) async {
      await tester.pumpWidget(buildOtp());
      await tester.pumpAndSettle();

      expect(find.text('Verification Code (OTP)'), findsOneWidget);
    });

    testWidgets('masked phone number appears in subtitle', (tester) async {
      await tester.pumpWidget(buildOtp());
      await tester.pumpAndSettle();

      expect(find.textContaining('081****5678'), findsOneWidget);
    });

    testWidgets('Resend button is visible', (tester) async {
      await tester.pumpWidget(buildOtp());
      await tester.pumpAndSettle();

      expect(find.text('Resend'), findsOneWidget);
    });

    testWidgets('Back button pops the screen', (tester) async {
      bool popped = false;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => const OtpVerificationScreen(
                  phoneNumber: kPhone,
                  username: kUsername,
                  password: kPassword,
                  email: kEmail,
                ),
              ),
            ).then((_) => popped = true),
            child: const Text('Go'),
          );
        }),
      ));

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('< Back'));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });

    testWidgets('typing in first OTP box accepts a digit', (tester) async {
      await tester.pumpWidget(buildOtp());
      await tester.pumpAndSettle();

      final first = find.byType(TextField).first;
      await tester.tap(first);
      await tester.pump();
      await tester.enterText(first, '7');
      await tester.pump();

      expect(find.text('7'), findsOneWidget);
    });
  });

  group('[Integration] CreateTransactionPinScreen – UI', () {
    testWidgets('title is shown', (tester) async {
      await tester.pumpWidget(buildCreate());
      await tester.pumpAndSettle();

      expect(find.text('Create a Transaction PIN'), findsOneWidget);
    });

    testWidgets('all digit buttons 0–9 are present', (tester) async {
      await tester.pumpWidget(buildCreate());
      await tester.pumpAndSettle();

      for (final d in ['0','1','2','3','4','5','6','7','8','9']) {
        expect(find.text(d), findsOneWidget, reason: 'Missing digit $d');
      }
    });

    testWidgets('backspace and check icons are present', (tester) async {
      await tester.pumpWidget(buildCreate());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('entering 6 digits does not crash', (tester) async {
      await tester.pumpWidget(buildCreate());
      await tester.pumpAndSettle();

      await enterPin(tester, kPin);

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('backspace removes last digit', (tester) async {
      await tester.pumpWidget(buildCreate());
      await tester.pumpAndSettle();

      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      // Still on same screen (pin reset to 0 digits)
      expect(find.text('Create a Transaction PIN'), findsOneWidget);
    });

    testWidgets('tapping check with <6 digits stays on screen', (tester) async {
      await tester.pumpWidget(buildCreate());
      await tester.pumpAndSettle();

      await enterPin(tester, '135'); // only 3 digits
      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();

      expect(find.text('Create a Transaction PIN'), findsOneWidget);
    });
  });

  group('[Integration] ConfirmTransactionPinScreen – UI', () {
    testWidgets('title is shown', (tester) async {
      await tester.pumpWidget(buildConfirm());
      await tester.pumpAndSettle();

      expect(find.text('Confirm Transaction Password'), findsOneWidget);
    });

    testWidgets('mismatched PIN shows snackbar', (tester) async {
      await tester.pumpWidget(buildConfirm(initialPin: '111111'));
      await tester.pumpAndSettle();

      await enterPin(tester, '222222'); // ≠ '111111'
      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('PIN tidak sama. Coba lagi.'), findsOneWidget);
    });

    testWidgets('after mismatch, input is cleared and new digit accepted',
        (tester) async {
      await tester.pumpWidget(buildConfirm(initialPin: '111111'));
      await tester.pumpAndSettle();

      // Wrong attempt
      await enterPin(tester, '999999');
      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('PIN tidak sama. Coba lagi.'), findsOneWidget);

      // Can enter a new digit immediately
      await tester.tap(find.text('1').first);
      await tester.pump();

      expect(find.text('Confirm Transaction Password'), findsOneWidget);
    });

    testWidgets('close (X) button is present', (tester) async {
      await tester.pumpWidget(buildConfirm());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });

}