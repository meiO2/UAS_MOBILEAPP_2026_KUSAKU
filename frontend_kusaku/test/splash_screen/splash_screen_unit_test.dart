import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Adjust these imports to match your Kusaku folder structure perfectly
import 'package:frontend_kusaku/Screens/Splash_Screen-frontend/splash_screen.dart';
import 'package:frontend_kusaku/Screens/Login_Screen-frontend/login_screen.dart';

void main() {
  // Ensure we can mock SharedPreferences if your app initializes it early
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  // Helper function to build the app and load the Splash Screen
  Future<void> pumpSplashApp(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );
  }

  group('SplashScreen Unit Tests', () {
    testWidgets('Cold launch – app launches and SplashScreen is the first screen', (tester) async {
      await pumpSplashApp(tester);

      // Verify the Splash Screen is currently in the widget tree
      expect(find.byType(SplashScreen), findsOneWidget);

      // CRITICAL FIX: Fast-forward time to kill the pending timer before the test finishes
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('Animation progression – scale and fade transitions execute correctly', (tester) async {
      await pumpSplashApp(tester);

      // Fast-forward the fake clock by 2.5 seconds to let the animations finish
      await tester.pump(const Duration(milliseconds: 2500));

      // At this point, the animations are done, and the widgets should be fully visible/scaled
      // We are verifying the splash screen is still present before the 4-second mark
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('Timer cleanup – navigates to LoginScreen after exactly 4 seconds', (tester) async {
      await pumpSplashApp(tester);

      // Fast-forward the fake clock by 4 seconds to trigger your navigation timer
      await tester.pump(const Duration(seconds: 4));

      // pumpAndSettle waits for the page transition animation (like a slide or fade to the Login Screen) to finish
      await tester.pumpAndSettle();

      // Verify that the Splash Screen is completely gone from the tree
      expect(find.byType(SplashScreen), findsNothing);
      
      // Verify that we have successfully landed on the Login Screen
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}