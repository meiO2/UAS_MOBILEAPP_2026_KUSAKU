import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:frontend_kusaku/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Cold launch – initial render', () {
    testWidgets('app launches and SplashScreen is the first screen',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      expect(find.byType(Scaffold), findsWidgets);

      // Verify background colour via the rendered Scaffold
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, const Color(0xFF93C5FD));
    });

    testWidgets('all three image assets are present at launch', (tester) async {
      app.main();
      await tester.pump(); // single frame — before any animations

      _expectAsset(tester, 'assets/images/Logo.png');
      _expectAsset(tester, 'assets/images/KUSAKU.png');
      _expectAsset(tester, 'assets/images/Ayo Atur Pengeluaranmu!.png');
    });
  });

  // -------------------------------------------------------------------------
  // 2. Animation progression on a real device
  // -------------------------------------------------------------------------
  group('Animation progression', () {
    testWidgets('scale starts small and grows over 2500 ms', (tester) async {
      app.main();
      await tester.pump();

      final scaleAt0 = _scaleValue(tester);
      expect(scaleAt0, lessThanOrEqualTo(0.5));

      await tester.pump(const Duration(milliseconds: 2500));

      final scaleAtEnd = _scaleValue(tester);
      expect(scaleAtEnd, greaterThan(scaleAt0));
      expect(scaleAtEnd, closeTo(1.0, 0.1));
    });

    testWidgets('tagline is invisible at launch and visible after 2500 ms',
        (tester) async {
      app.main();
      await tester.pump();

      expect(_fadeValue(tester), closeTo(0.0, 0.05));

      await tester.pump(const Duration(milliseconds: 2500));

      expect(_fadeValue(tester), greaterThan(0.5));
    });

    testWidgets('logo rotation starts after 1250 ms', (tester) async {
      app.main();
      await tester.pump();

      final rotationBefore = _rotationValue(tester);

      await tester.pump(const Duration(milliseconds: 1250));
      await tester.pump(const Duration(milliseconds: 200)); // one tick of rotation

      final rotationAfter = _rotationValue(tester);
      expect(rotationAfter, isNot(equals(rotationBefore)));
    });
  });

  // -------------------------------------------------------------------------
  // 3. Automatic navigation to LoginScreen
  // -------------------------------------------------------------------------
  group('Navigation to LoginScreen', () {
    testWidgets('SplashScreen is still shown at 3 s', (tester) async {
      app.main();
      await tester.pump(const Duration(seconds: 3));

      // Background colour is still splash blue
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, const Color(0xFF93C5FD));
    });

    testWidgets('navigates to LoginScreen after exactly 4 s', (tester) async {
      app.main();

      // Pump up to 4 s total
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // SplashScreen background should be gone
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, isNot(const Color(0xFF93C5FD)));

      // LoginScreen-specific widget (adjust finder to match your LoginScreen)
      expect(_loginScreenVisible(tester), isTrue);
    });

    testWidgets('back navigation is disabled after reaching LoginScreen',
        (tester) async {
      app.main();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      final NavigatorState nav = tester.state(find.byType(Navigator));
      expect(nav.canPop(), isFalse,
          reason: 'pushReplacement should clear the back stack');
    });
  });

  // -------------------------------------------------------------------------
  // 4. Full end-to-end smoke test
  // -------------------------------------------------------------------------
  group('End-to-end smoke test', () {
    testWidgets('complete splash → login journey completes without error',
        (tester) async {
      app.main();

      // Frame 0 — splash visible
      await tester.pump();
      expect(_splashVisible(tester), isTrue);

      // Mid-animation
      await tester.pump(const Duration(milliseconds: 1250));
      expect(_splashVisible(tester), isTrue);

      // Animation complete, still on splash
      await tester.pump(const Duration(milliseconds: 1250));
      expect(_splashVisible(tester), isTrue);

      // Timer fires → navigate
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(_splashVisible(tester), isFalse);
      expect(_loginScreenVisible(tester), isTrue);
    });
  });
}

// =============================================================================
// Private helpers
// =============================================================================

/// Whether the SplashScreen's distinctive blue background is on screen.
bool _splashVisible(WidgetTester tester) {
  try {
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    return scaffold.backgroundColor == const Color(0xFF93C5FD);
  } catch (_) {
    return false;
  }
}

/// Whether the LoginScreen is on screen.
/// Adjust the finder to match a widget unique to your real LoginScreen.
bool _loginScreenVisible(WidgetTester tester) {
  // Example: find a widget with key or text that only exists on LoginScreen.
  // Replace 'Login' with the actual text / key in your LoginScreen.
  return find.textContaining('Login').evaluate().isNotEmpty ||
      find.byKey(const Key('loginScreen')).evaluate().isNotEmpty;
}

/// Current value of the ScaleTransition animation.
double _scaleValue(WidgetTester tester) {
  final st = tester.widget<ScaleTransition>(find.byType(ScaleTransition).first);
  return st.scale.value;
}

/// Current opacity value of the FadeTransition animation.
double _fadeValue(WidgetTester tester) {
  final ft = tester.widget<FadeTransition>(find.byType(FadeTransition).first);
  return ft.opacity.value;
}

/// Current turns value of the RotationTransition animation.
double _rotationValue(WidgetTester tester) {
  final rt =
      tester.widget<RotationTransition>(find.byType(RotationTransition).first);
  return rt.turns.value;
}

/// Asserts that an Image with the given asset path exists in the widget tree.
void _expectAsset(WidgetTester tester, String assetName) {
  expect(
    find.byWidgetPredicate(
      (w) => w is Image && (w.image as AssetImage).assetName == assetName,
    ),
    findsOneWidget,
    reason: 'Expected asset "$assetName" to be present',
  );
}