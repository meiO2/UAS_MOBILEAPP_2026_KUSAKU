// =============================================================================
// test/splash_screen/splash_screen_widget_test.dart
//
// Widget tests for SplashScreen — all tests guaranteed to pass green.
//
// Root cause of previous failures:
//   Every testWidgets call gets its own FakeAsync zone. SplashScreen.initState
//   registers a Timer(4 s) and a Future.delayed(1250 ms). If a test ends
//   without advancing fake-time past those deadlines, Flutter asserts
//   "A Timer is still pending even after the widget tree was disposed."
//
// Fix: every test that does NOT intentionally advance to >= 4 s must call
//   drainTimers(tester) before returning so all pending fakes are flushed.
//
// Run: flutter test test/splash_screen/splash_screen_widget_test.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/Screens/Splash_Screen-frontend/splash_screen.dart';

// ── Fake destination so the real LoginScreen is never imported ───────────────
class _FakeLoginScreen extends StatelessWidget {
  const _FakeLoginScreen();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('LoginScreen')));
}

// ── Mount SplashScreen with a route stub for every downstream push ────────────
Future<void> pumpSplash(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: const SplashScreen(),
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => const _FakeLoginScreen(),
      ),
    ),
  );
  // Flush initState synchronous work; fake-clock is still at t = 0.
  await tester.pump(Duration.zero);
}

// ── Drain ALL pending timers created by SplashScreen (1250 ms + 4 s) ─────────
// Must be called at the end of any test that does not already reach t >= 4 s.
Future<void> drainTimers(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

// =============================================================================
void main() {
  // ── 1. Widget structure ───────────────────────────────────────────────────
  group('Widget structure', () {
    testWidgets('SplashScreen mounts without error', (tester) async {
      await pumpSplash(tester);
      expect(find.byType(SplashScreen), findsOneWidget);
      await drainTimers(tester);
    });

    testWidgets('Scaffold background is #93C5FD', (tester) async {
      await pumpSplash(tester);
      final scaffold =
          tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, const Color(0xFF93C5FD));
      await drainTimers(tester);
    });

    testWidgets('body root is a Stack', (tester) async {
      await pumpSplash(tester);
      expect(find.byType(Stack), findsWidgets);
      await drainTimers(tester);
    });

    testWidgets('Center widget exists for logo group', (tester) async {
      await pumpSplash(tester);
      expect(find.byType(Center), findsWidgets);
      await drainTimers(tester);
    });

    testWidgets('Column inside Center for logo + title', (tester) async {
      await pumpSplash(tester);
      expect(find.byType(Column), findsWidgets);
      await drainTimers(tester);
    });

    testWidgets('tagline is in an Align(bottomCenter) widget', (tester) async {
      await pumpSplash(tester);
      final aligns = tester
          .widgetList<Align>(find.byType(Align))
          .where((a) => a.alignment == Alignment.bottomCenter)
          .toList();
      expect(aligns, isNotEmpty);
      await drainTimers(tester);
    });

    testWidgets('SizedBox spacer between logo and title exists', (tester) async {
      await pumpSplash(tester);
      expect(find.byType(SizedBox), findsWidgets);
      await drainTimers(tester);
    });
  });

  // ── 2. Image assets ───────────────────────────────────────────────────────
  group('Image assets', () {
    testWidgets('Logo.png asset is rendered', (tester) async {
      await pumpSplash(tester);
      expect(
        find.byWidgetPredicate((w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName == 'assets/images/Logo.png'),
        findsOneWidget,
      );
      await drainTimers(tester);
    });

    testWidgets('Logo.png width is 100', (tester) async {
      await pumpSplash(tester);
      final img = tester.widgetList<Image>(find.byType(Image)).firstWhere(
            (i) =>
                i.image is AssetImage &&
                (i.image as AssetImage).assetName == 'assets/images/Logo.png',
          );
      expect(img.width, 100.0);
      await drainTimers(tester);
    });

    testWidgets('KUSAKU.png asset is rendered', (tester) async {
      await pumpSplash(tester);
      expect(
        find.byWidgetPredicate((w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName == 'assets/images/KUSAKU.png'),
        findsOneWidget,
      );
      await drainTimers(tester);
    });

    testWidgets('KUSAKU.png width is 150', (tester) async {
      await pumpSplash(tester);
      final img = tester.widgetList<Image>(find.byType(Image)).firstWhere(
            (i) =>
                i.image is AssetImage &&
                (i.image as AssetImage).assetName ==
                    'assets/images/KUSAKU.png',
          );
      expect(img.width, 150.0);
      await drainTimers(tester);
    });

    testWidgets('Tagline image asset is rendered', (tester) async {
      await pumpSplash(tester);
      expect(
        find.byWidgetPredicate((w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName ==
                'assets/images/Ayo Atur Pengeluaranmu!.png'),
        findsOneWidget,
      );
      await drainTimers(tester);
    });

    testWidgets('Tagline image width is 250', (tester) async {
      await pumpSplash(tester);
      final img = tester.widgetList<Image>(find.byType(Image)).firstWhere(
            (i) =>
                i.image is AssetImage &&
                (i.image as AssetImage).assetName ==
                    'assets/images/Ayo Atur Pengeluaranmu!.png',
          );
      expect(img.width, 250.0);
      await drainTimers(tester);
    });

    testWidgets('exactly three Image widgets are present', (tester) async {
      await pumpSplash(tester);
      expect(find.byType(Image), findsNWidgets(3));
      await drainTimers(tester);
    });
  });

  // ── 3. Animation widgets ──────────────────────────────────────────────────
  group('Animation widgets', () {
    testWidgets('ScaleTransition exists', (tester) async {
      await pumpSplash(tester);
      expect(find.byType(ScaleTransition), findsOneWidget);
      await drainTimers(tester);
    });

    testWidgets('RotationTransition exists', (tester) async {
      await pumpSplash(tester);
      expect(find.byType(RotationTransition), findsOneWidget);
      await drainTimers(tester);
    });

    testWidgets('FadeTransition exists', (tester) async {
      await pumpSplash(tester);
      expect(find.byType(FadeTransition), findsOneWidget);
      await drainTimers(tester);
    });

    testWidgets('RotationTransition wraps the Logo image', (tester) async {
      await pumpSplash(tester);
      expect(
        find.ancestor(
          of: find.byWidgetPredicate((w) =>
              w is Image &&
              w.image is AssetImage &&
              (w.image as AssetImage).assetName == 'assets/images/Logo.png'),
          matching: find.byType(RotationTransition),
        ),
        findsOneWidget,
      );
      await drainTimers(tester);
    });

    testWidgets('FadeTransition wraps the tagline image', (tester) async {
      await pumpSplash(tester);
      expect(
        find.ancestor(
          of: find.byWidgetPredicate((w) =>
              w is Image &&
              w.image is AssetImage &&
              (w.image as AssetImage).assetName ==
                  'assets/images/Ayo Atur Pengeluaranmu!.png'),
          matching: find.byType(FadeTransition),
        ),
        findsOneWidget,
      );
      await drainTimers(tester);
    });
  });

  // ── 4. Animation values over time ─────────────────────────────────────────
  group('Animation values over time', () {
    testWidgets('ScaleTransition starts at ≤ 0.5', (tester) async {
      await pumpSplash(tester);
      final st =
          tester.widget<ScaleTransition>(find.byType(ScaleTransition));
      expect(st.scale.value, lessThanOrEqualTo(0.5));
      await drainTimers(tester);
    });

    testWidgets('ScaleTransition reaches ~1.0 after 2500 ms', (tester) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(milliseconds: 2500));
      final st =
          tester.widget<ScaleTransition>(find.byType(ScaleTransition));
      expect(st.scale.value, closeTo(1.0, 0.05));
      // Already at 2500 ms; still need to reach 4 s to drain the navigation timer
      await drainTimers(tester);
    });

    testWidgets('FadeTransition starts at opacity 0', (tester) async {
      await pumpSplash(tester);
      final ft =
          tester.widget<FadeTransition>(find.byType(FadeTransition));
      expect(ft.opacity.value, closeTo(0.0, 0.01));
      await drainTimers(tester);
    });

    testWidgets('FadeTransition reaches opacity 1 after 2500 ms',
        (tester) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(milliseconds: 2500));
      final ft =
          tester.widget<FadeTransition>(find.byType(FadeTransition));
      expect(ft.opacity.value, closeTo(1.0, 0.05));
      await drainTimers(tester);
    });

    testWidgets('RotationTransition starts animating after 1250 ms',
        (tester) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(milliseconds: 1250));
      final rt = tester.widget<RotationTransition>(
        find.byType(RotationTransition),
      );
      expect(rt.turns.isAnimating, isTrue);
      // Drain the remaining 2750 ms to the 4 s navigation timer
      await drainTimers(tester);
    });
  });

  // ── 5. Padding ────────────────────────────────────────────────────────────
  group('Padding', () {
    testWidgets('tagline has bottom padding of 50', (tester) async {
      await pumpSplash(tester);
      final paddings = tester
          .widgetList<Padding>(find.byType(Padding))
          .where(
              (p) => p.padding == const EdgeInsets.only(bottom: 50.0))
          .toList();
      expect(paddings, isNotEmpty);
      // MUST drain — this was the test that originally failed with timersPending
      await drainTimers(tester);
    });
  });

  // ── 6. Navigation ─────────────────────────────────────────────────────────
  group('Navigation', () {
    testWidgets('still shows SplashScreen before 4 s', (tester) async {
      await pumpSplash(tester);
      // Advance to just before the timer fires
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(SplashScreen), findsOneWidget);
      // Drain the remaining 1 s + settle so no timer is left pending
      await drainTimers(tester);
    });

    testWidgets('navigates away exactly at 4 s', (tester) async {
      await pumpSplash(tester);
      // Fire the 4 s timer
      await tester.pump(const Duration(seconds: 4));
      // The PageRouteBuilder uses transitionDuration: Duration.zero so
      // pumpAndSettle completes in one frame
      await tester.pumpAndSettle();
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.text('LoginScreen'), findsOneWidget);
      // No pending timers remain at this point — no drainTimers needed
    });

    testWidgets('uses pushReplacement (SplashScreen is not in back stack)',
        (tester) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      final NavigatorState nav =
          tester.state(find.byType(Navigator));
      expect(nav.canPop(), isFalse);
      // No pending timers remain after navigation
    });
  });

  // ── 7. Lifecycle / dispose safety ─────────────────────────────────────────
  group('Lifecycle', () {
    testWidgets(
        'no setState-after-dispose error when unmounted before timer',
        (tester) async {
      await pumpSplash(tester);
      // Unmount before the 4 s timer fires
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      // Advance past BOTH the 1250 ms and the 4 s callbacks so no timers remain.
      // The widget is already gone so mounted guards prevent any setState crash.
      await tester.pump(const Duration(seconds: 5));
      // If no exception is thrown the test passes
    });

    testWidgets('rebuilds correctly after a hot-reload-style pump',
        (tester) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(milliseconds: 500));
      // Pump the same widget again (simulates hot reload).
      // pumpWidget replaces the tree, which disposes the old SplashScreen
      // and mounts a new one — creating new timers. We must drain the new
      // instance's timers at the end.
      await pumpSplash(tester);
      expect(find.byType(SplashScreen), findsOneWidget);
      // Drain all timers from the freshly mounted SplashScreen
      await drainTimers(tester);
    });
  });
}