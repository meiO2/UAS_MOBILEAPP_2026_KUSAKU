// =============================================================================
// test/splash_screen/splash_screen_widget_test.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/Screens/Splash_Screen-frontend/splash_screen.dart';

// ── Fake destination so MaterialPageRoute is satisfied, though SplashScreen ──
// ── uses PageRouteBuilder which directly mounts the real LoginScreen. ────────
class _FakeLoginScreen extends StatelessWidget {
  const _FakeLoginScreen();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('LoginScreen')));
}

Future<void> pumpSplash(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: const SplashScreen(),
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => const _FakeLoginScreen(),
      ),
    ),
  );
  await tester.pump(Duration.zero);
}

Future<void> drainTimers(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

// ── NEW: Pinpoint Finders ────────────────────────────────────────────────────
// Flutter's Scaffold secretly builds its own hidden Fade/Scale/Rotation 
// transitions for the FloatingActionButton (even when one isn't used!).
// By checking the 'child' property, we guarantee we only find YOUR animations.

final Finder myScaleFinder = find.byWidgetPredicate(
  (w) => w is ScaleTransition && w.child is Column
);

final Finder myRotationFinder = find.byWidgetPredicate(
  (w) => w is RotationTransition && w.child is Image
);

final Finder myFadeFinder = find.byWidgetPredicate(
  (w) => w is FadeTransition && w.child is Image
);

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
      expect(myScaleFinder, findsOneWidget);
      await drainTimers(tester);
    });

    testWidgets('RotationTransition exists', (tester) async {
      await pumpSplash(tester);
      expect(myRotationFinder, findsOneWidget);
      await drainTimers(tester);
    });

    testWidgets('FadeTransition exists', (tester) async {
      await pumpSplash(tester);
      expect(myFadeFinder, findsOneWidget);
      await drainTimers(tester);
    });

    testWidgets('RotationTransition wraps the Logo image', (tester) async {
      await pumpSplash(tester);
      final rotationWidget = tester.widget<RotationTransition>(myRotationFinder);
      final imageWidget = rotationWidget.child as Image;
      expect((imageWidget.image as AssetImage).assetName, 'assets/images/Logo.png');
      await drainTimers(tester);
    });

    testWidgets('FadeTransition wraps the tagline image', (tester) async {
      await pumpSplash(tester);
      final fadeWidget = tester.widget<FadeTransition>(myFadeFinder);
      final imageWidget = fadeWidget.child as Image;
      expect((imageWidget.image as AssetImage).assetName, 'assets/images/Ayo Atur Pengeluaranmu!.png');
      await drainTimers(tester);
    });
  });

  // ── 4. Animation values over time ─────────────────────────────────────────
  group('Animation values over time', () {
    testWidgets('ScaleTransition starts at ≤ 0.5', (tester) async {
      await pumpSplash(tester);
      final st = tester.widget<ScaleTransition>(myScaleFinder);
      expect(st.scale.value, lessThanOrEqualTo(0.5));
      await drainTimers(tester);
    });

    testWidgets('ScaleTransition reaches ~1.0 after 2500 ms', (tester) async {
      await pumpSplash(tester);
      await Future.delayed(const Duration(milliseconds: 2500));
      await tester.pump(); // Renders the frame at the 2.5-second mark
      final st = tester.widget<ScaleTransition>(myScaleFinder);
      expect(st.scale.value, closeTo(1.0, 0.05));
      await drainTimers(tester);
    });

    testWidgets('FadeTransition starts at opacity 0', (tester) async {
      await pumpSplash(tester);
      final ft = tester.widget<FadeTransition>(myFadeFinder);
      expect(ft.opacity.value, closeTo(0.0, 0.01));
      await drainTimers(tester);
    });

    testWidgets('FadeTransition reaches opacity 1 after 2500 ms',
        (tester) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(milliseconds: 2500));
      final ft = tester.widget<FadeTransition>(myFadeFinder);
      expect(ft.opacity.value, closeTo(1.0, 0.05));
      await drainTimers(tester);
    });

    testWidgets('RotationTransition starts animating after 1250 ms',
        (tester) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(milliseconds: 1250));
      final rt = tester.widget<RotationTransition>(myRotationFinder);
      expect(rt.turns.isAnimating, isTrue);
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
      await drainTimers(tester);
    });
  });

  // ── 6. Navigation ─────────────────────────────────────────────────────────
  group('Navigation', () {
    testWidgets('still shows SplashScreen before 4 s', (tester) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(SplashScreen), findsOneWidget);
      await drainTimers(tester);
    });

    testWidgets('navigates away exactly at 4 s', (tester) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      
      expect(find.byType(SplashScreen), findsNothing);
      expect(
        find.byWidgetPredicate((w) => w.runtimeType.toString() == 'LoginScreen'),
        findsOneWidget,
      );
    });

    testWidgets('uses pushReplacement (SplashScreen is not in back stack)',
        (tester) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      final NavigatorState nav =
          tester.state(find.byType(Navigator));
      expect(nav.canPop(), isFalse);
    });
  });

  // ── 7. Lifecycle / dispose safety ─────────────────────────────────────────
  group('Lifecycle', () {
    testWidgets(
        'no setState-after-dispose error when unmounted before timer',
        (tester) async {
      await pumpSplash(tester);
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('rebuilds correctly after a hot-reload-style pump',
        (tester) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(milliseconds: 500));
      await pumpSplash(tester);
      expect(find.byType(SplashScreen), findsOneWidget);
      await drainTimers(tester);
    });
  });
}