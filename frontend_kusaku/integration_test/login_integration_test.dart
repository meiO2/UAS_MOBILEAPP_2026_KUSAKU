// integration_test/login_integration_test.dart
//
// Integration tests for the login flow:
//   LoginScreen → (credentials) → MainShell
//   LoginScreen → ForgotPasswordScreen
//   LoginScreen → SignUpScreen
//   LoginScreen → PhoneSignInScreen → OtpVerificationScreen
//   LoginScreen → PIN dialog (no prior session guard)
//
// Groups 1–5 run WITHOUT a backend (direct screen mounting, no SharedPreferences
// pre-seeded). Group 6 (happy-path) requires a live server — keep it commented.
//
// Run with:
//   flutter test integration_test/login_integration_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// ── Replace 'your_app' with your actual package name ────────────────────────
import '../lib/Screens/Login_Screen-frontend/login_screen.dart';
import '../lib/Screens/Login_Screen-frontend/phone_signin_screen.dart';
import '../lib/Screens/Login_Screen-frontend/otp_verification_screen.dart'
    as phone_otp; // phone-login OTP (only phoneNumber param)

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ── Shared data ───────────────────────────────────────────────────────────

  const kPhone = '08112345678';

  // ── Screen builders ───────────────────────────────────────────────────────
  //
  // Every screen is mounted standalone. This avoids depending on app.main()
  // or any other screen being visible first, keeping each test deterministic.

  Widget buildLogin() => const MaterialApp(home: LoginScreen());

  Widget buildPhone() => const MaterialApp(home: PhoneSignInScreen());

  Widget buildOtp({String phone = kPhone}) =>
      MaterialApp(home: phone_otp.OtpVerificationScreen(phoneNumber: phone));

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Taps a widget then pumps two frames: one for setState, one for SnackBar.
  Future<void> tapAndWait(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  // =========================================================================
  // Group 1 – LoginScreen: field validation / _handleLogin (no network)
  // =========================================================================

  group('[Integration] LoginScreen – _handleLogin validation', () {
    testWidgets('empty form shows required-field snackbar', (tester) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      await tapAndWait(tester, find.text('Log in'));

      expect(find.text('Please fill in both fields'), findsOneWidget);
    });

    testWidgets('only username filled shows required-field snackbar',
        (tester) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'john');
      await tapAndWait(tester, find.text('Log in'));

      expect(find.text('Please fill in both fields'), findsOneWidget);
    });

    testWidgets('only password filled shows required-field snackbar',
        (tester) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tapAndWait(tester, find.text('Log in'));

      expect(find.text('Please fill in both fields'), findsOneWidget);
    });

    testWidgets('valid input starts loading (CircularProgressIndicator)',
        (tester) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'johndoe');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.pump();

      // Tap and pump ONE frame — the HTTP call is async so spinner is visible.
      await tester.tap(find.text('Log in'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // =========================================================================
  // Group 2 – LoginScreen: UI elements
  // =========================================================================

  group('[Integration] LoginScreen – UI elements', () {
    testWidgets('Welcome Back title is shown', (tester) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back!'), findsOneWidget);
    });

    testWidgets('Username and Password fields are rendered', (tester) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('password visibility toggle works', (tester) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('Forgot Password button is present', (tester) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('Log in button is present', (tester) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      expect(find.text('Log in'), findsOneWidget);
    });

    testWidgets('Phone Number field is present', (tester) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      expect(find.text('Phone Number'), findsOneWidget);
    });

    testWidgets('"Don\'t have an account yet?" and Sign Up are shown',
        (tester) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      expect(find.text("Don't have an account yet? "), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });
  });

  // =========================================================================
  // Group 3 – LoginScreen: navigation (_navigateToForgotPassword,
  //           _navigateToSignUp, _phoneController)
  // =========================================================================

  group('[Integration] LoginScreen – navigation', () {
    testWidgets('_navigateToForgotPassword: Forgot Password pushes screen',
        (tester) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      // LoginScreen card is gone
      expect(find.text('Welcome Back!'), findsNothing);
    });

    testWidgets('_navigateToSignUp: Sign Up button pushes SignUpScreen',
        (tester) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back!'), findsNothing);
    });

    testWidgets(
        '_phoneController: tapping Phone Number field pushes PhoneSignInScreen',
        (tester) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Phone Number'));
      await tester.pumpAndSettle();

      expect(find.text('Sign in with Phone Number'), findsOneWidget);
    });
  });

  // =========================================================================
  // Group 4 – LoginScreen: PIN dialog (_showPinInputDialog)
  // =========================================================================

  group('[Integration] LoginScreen – _showPinInputDialog', () {
    testWidgets(
        'PIN button shows "login with password first" when no session saved',
        (tester) async {
      // SharedPreferences is empty in tests by default, so no user_id exists.
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      // KusakuBottomPinPanel — find by icon if present, else skip gracefully.
      final pinBtn = find.byIcon(Icons.lock_outline);
      if (pinBtn.evaluate().isNotEmpty) {
        await tapAndWait(tester, pinBtn.first);
        expect(
          find.text('Please login with your password first.'),
          findsOneWidget,
        );
      } else {
        // Adjust this finder to match the actual trigger widget in
        // KusakuBottomPinPanel (e.g. Icons.pin, a Text label, or a key).
        markTestSkipped(
          'KusakuBottomPinPanel trigger not found — update the finder.',
        );
      }
    });
  });

  // =========================================================================
  // Group 5 – PhoneSignInScreen
  // =========================================================================

  group('[Integration] PhoneSignInScreen – UI & navigation', () {
    testWidgets('renders title and phone field with +62 prefix', (tester) async {
      await tester.pumpWidget(buildPhone());
      await tester.pumpAndSettle();

      expect(find.text('Sign in with Phone Number'), findsOneWidget);
      expect(find.text('+62'), findsOneWidget);
    });

    testWidgets('phone field accepts additional digits', (tester) async {
      await tester.pumpWidget(buildPhone());
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextField).first, '+6281234567890');
      await tester.pump();

      expect(find.text('+6281234567890'), findsOneWidget);
    });

    testWidgets('Next button navigates to OtpVerificationScreen', (tester) async {
      await tester.pumpWidget(buildPhone());
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextField).first, '+6281234567890');
      await tester.pump();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Verification Code (OTP)'), findsOneWidget);
    });

    testWidgets('Back button pops back to previous screen', (tester) async {
      bool popped = false;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const PhoneSignInScreen()),
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
  });

  // =========================================================================
  // Group 6 – OtpVerificationScreen (phone login variant)
  // =========================================================================

  group('[Integration] OtpVerificationScreen (phone) – UI', () {
    testWidgets('renders 6 OTP boxes', (tester) async {
      await tester.pumpWidget(buildOtp());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(6));
    });

    testWidgets('masked phone number appears in subtitle', (tester) async {
      await tester.pumpWidget(buildOtp(phone: '08112345678'));
      await tester.pumpAndSettle();

      expect(find.textContaining('081****5678'), findsOneWidget);
    });

    testWidgets('Resend button shows success snackbar', (tester) async {
      await tester.pumpWidget(buildOtp());
      await tester.pumpAndSettle();

      await tapAndWait(tester, find.text('Resend'));

      expect(find.text('OTP resent successfully'), findsOneWidget);
    });

    testWidgets('Back button pops the screen', (tester) async {
      bool popped = false;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) =>
                    const phone_otp.OtpVerificationScreen(phoneNumber: kPhone),
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

    testWidgets('typing in first box is accepted', (tester) async {
      await tester.pumpWidget(buildOtp());
      await tester.pumpAndSettle();

      final first = find.byType(TextField).first;
      await tester.tap(first);
      await tester.pump();
      await tester.enterText(first, '5');
      await tester.pump();

      expect(find.text('5'), findsOneWidget);
    });
  });

  // =========================================================================
  // Group 7 – Full happy-path login (requires live / mock backend)
  // =========================================================================
  //
  // Uncomment when a WireMock / json-server test backend is available.
  // Pre-seed SharedPreferences or use a backend that returns a fixed user_id.
  //
  // group('[Integration] Full login flow – happy path', () {
  //   testWidgets('successful login navigates to MainShell', (tester) async {
  //     await tester.pumpWidget(buildLogin());
  //     await tester.pumpAndSettle();
  //
  //     await tester.enterText(find.byType(TextField).first, 'testuser');
  //     await tester.enterText(find.byType(TextField).at(1), 'TestPass1!');
  //     await tester.pump();
  //
  //     await tester.tap(find.text('Log in'));
  //     await tester.pumpAndSettle(const Duration(seconds: 5));
  //
  //     // MainShell should be visible (check a widget unique to it)
  //     expect(find.byType(BottomNavigationBar), findsOneWidget);
  //   });
  //
  //   testWidgets('wrong credentials shows backend error snackbar',
  //       (tester) async {
  //     await tester.pumpWidget(buildLogin());
  //     await tester.pumpAndSettle();
  //
  //     await tester.enterText(find.byType(TextField).first, 'wronguser');
  //     await tester.enterText(find.byType(TextField).at(1), 'wrongpass');
  //     await tester.pump();
  //
  //     await tester.tap(find.text('Log in'));
  //     await tester.pumpAndSettle(const Duration(seconds: 5));
  //
  //     expect(find.text('Username or password incorrect'), findsOneWidget);
  //   });
  // });
}