// =============================================================================
// integration_test/splash_screen_integration_test.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// IMPORTANT: Adjust these paths if your folder structure is slightly different
import '../../lib/Screens/Splash_Screen-frontend/splash_screen.dart';
import '../../lib/Screens/Login_Screen-frontend/login_screen.dart';

// Helper finders to avoid matching hidden transitions from MaterialApp/Scaffold
final Finder myScaleFinder = find.byWidgetPredicate(
  (w) => w is ScaleTransition && w.child is Column
);

final Finder myFadeFinder = find.byWidgetPredicate(
  (w) => w is FadeTransition && w.child is Image
);

void main() {
  // This line is required for Integration Tests to interact with the device/emulator
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Helper function to boot up the widget
  Future<void> pumpSplashApp(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );
    await tester.pump(); // Render the very first frame
  }

  group('Cold launch – initial render', () {
    testWidgets('app launches and SplashScreen is the first screen', (tester) async {
      await pumpSplashApp(tester);
      expect(find.byType(SplashScreen), findsOneWidget);
    });
  });

  group('Animation progression', () {
    testWidgets('scale starts small and grows over 2500 ms', (tester) async {
      await pumpSplashApp(tester);
      
      // Check initial scale
      final stInitial = tester.widget<ScaleTransition>(myScaleFinder);
      expect(stInitial.scale.value, lessThanOrEqualTo(0.5));

      // Wait in REAL time for the animation to run
      await Future.delayed(const Duration(milliseconds: 2500));
      await tester.pump(); // Render the screen at the 2.5s mark
      
      // Check final scale
      final stFinal = tester.widget<ScaleTransition>(myScaleFinder);
      expect(stFinal.scale.value, closeTo(1.0, 0.05));
    });

    testWidgets('tagline is invisible at launch and visible after 2500 ms', (tester) async {
      await pumpSplashApp(tester);

      // Check initial opacity
      final ftInitial = tester.widget<FadeTransition>(myFadeFinder);
      expect(ftInitial.opacity.value, closeTo(0.0, 0.01));

      // Wait in REAL time for the animation to run
      await Future.delayed(const Duration(milliseconds: 2500));
      await tester.pump(); // Render the screen at the 2.5s mark

      // Check final opacity
      final ftFinal = tester.widget<FadeTransition>(myFadeFinder);
      expect(ftFinal.opacity.value, closeTo(1.0, 0.05));
    });
  });

  group('Navigation to LoginScreen', () {
    testWidgets('navigates to LoginScreen after exactly 4 s', (tester) async {
      await pumpSplashApp(tester);

      // Wait just past the 4-second timer (4.5s) to allow the routing to complete
      await Future.delayed(const Duration(milliseconds: 4500));
      
      // We can use pumpAndSettle here because the splash screen (and its spinning logo) 
      // has been destroyed by the pushReplacement, so there are no infinite animations left.
      await tester.pumpAndSettle(); 

      // Verify the splash is gone and the login screen is present
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('End-to-end smoke test', () {
    testWidgets('complete splash → login journey completes without error', (tester) async {
      await pumpSplashApp(tester);

      // Wait the full duration for everything to run its course naturally
      await Future.delayed(const Duration(milliseconds: 4500));
      await tester.pumpAndSettle();

      // If we made it to the LoginScreen without crashing, the smoke test passes
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}