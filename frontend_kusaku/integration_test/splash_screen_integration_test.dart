import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../../frontend_kusaku/lib/Screens/Splash_Screen-frontend/splash_screen.dart';
import '../lib/Screens/Login_Screen-frontend/login_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ── THE MAGIC FIX: The Ticking Clock ───────────────────────────────────────
  // Because your logo spins infinitely, we cannot use tester.pumpAndSettle().
  // Instead, we manually tick the clock every 50ms. This forces the emulator 
  // to draw the animation frames AND allows the 4-second Timer to fire.
  // ── THE REAL-TIME TICKING CLOCK ────────────────────────────────────────────
  Future<void> pumpFor(WidgetTester tester, Duration duration) async {
    // Calculate exactly when we should stop waiting in the real world
    final DateTime endTime = DateTime.now().add(duration);
    
    // Keep looping until real-world time has passed
    while (DateTime.now().isBefore(endTime)) {
      await tester.pump(); // Force the UI to redraw the current frame
      await Future.delayed(const Duration(milliseconds: 50)); // Wait in real-time
    }
  }

  // ── Pinpoint Finders ───────────────────────────────────────────────────────
  // These ensure we only grab YOUR animations, ignoring Flutter's hidden ones.
  final Finder myScaleFinder = find.descendant(
    of: find.byType(SplashScreen),
    matching: find.byWidgetPredicate((w) => w is ScaleTransition && w.child is Column),
  );

  final Finder myFadeFinder = find.descendant(
    of: find.byType(SplashScreen),
    matching: find.byWidgetPredicate((w) => w is FadeTransition && w.child is Image),
  );

  Future<void> launchSplash(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );
    await tester.pump();
  }

  group('Cold launch – initial render', () {
    testWidgets('app launches and SplashScreen is the first screen', (tester) async {
      await launchSplash(tester);
      expect(find.byType(SplashScreen), findsOneWidget);
    });
  });

  group('Animation progression', () {
    testWidgets('scale starts small and grows over 2500 ms', (tester) async {
      await launchSplash(tester);
      
      final stInitial = tester.widget<ScaleTransition>(myScaleFinder.first);
      expect(stInitial.scale.value, lessThanOrEqualTo(0.5));

      // Force the UI to play 2.6 seconds of the animation
      await pumpFor(tester, const Duration(milliseconds: 2600));
      
      final stFinal = tester.widget<ScaleTransition>(myScaleFinder.first);
      expect(stFinal.scale.value, greaterThan(0.5));
    });

    testWidgets('tagline is invisible at launch and visible after 2500 ms', (tester) async {
      await launchSplash(tester);

      final ftInitial = tester.widget<FadeTransition>(myFadeFinder.first);
      expect(ftInitial.opacity.value, closeTo(0.0, 0.05));

      // Force the UI to play 2.6 seconds of the animation
      await pumpFor(tester, const Duration(milliseconds: 2600));

      final ftFinal = tester.widget<FadeTransition>(myFadeFinder.first);
      expect(ftFinal.opacity.value, greaterThan(0.9));
    });
  });

  group('Navigation to LoginScreen', () {
    testWidgets('navigates to LoginScreen after exactly 4 s', (tester) async {
      await launchSplash(tester);

      // Play the app forward for 4.5 seconds to ensure the 4-second Timer 
      // fires and the route transition has time to complete.
      await pumpFor(tester, const Duration(milliseconds: 4500));

      // Check that the LoginScreen exists in the widget tree (returns true)
      expect(find.byType(LoginScreen).evaluate().isNotEmpty, true);
    });
  });

  group('End-to-end smoke test', () {
    testWidgets('complete splash → login journey completes without error', (tester) async {
      await launchSplash(tester);

      // Play the entire splash screen sequence forward
      await pumpFor(tester, const Duration(milliseconds: 4500));

      // Verify we successfully arrived at the LoginScreen
      expect(find.byType(LoginScreen).evaluate().isNotEmpty, true);
    });
  });
}