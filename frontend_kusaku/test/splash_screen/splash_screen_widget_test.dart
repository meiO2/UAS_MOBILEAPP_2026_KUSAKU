import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/Screens/Splash_Screen-frontend/splash_screen.dart';

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
}

void main() {
  group('Widget structure', () {
    testWidgets('SplashScreen mounts without error', (tester) async {
      await pumpSplash(tester);
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('Scaffold background is #93C5FD', (tester) async {
      await pumpSplash(tester);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, const Color(0xFF93C5FD));
    });

    testWidgets('body root is a Stack', (tester) async {
      await pumpSplash(tester);
      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('Center widget exists for logo group', (tester) async {
      await pumpSplash(tester);
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('Column inside Center for logo + title', (tester) async {
      await pumpSplash(tester);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('tagline is in an Align(bottomCenter) widget', (tester) async {
      await pumpSplash(tester);
      final aligns = tester
          .widgetList<Align>(find.byType(Align))
          .where((a) => a.alignment == Alignment.bottomCenter)
          .toList();
      expect(aligns, isNotEmpty);
    });

    testWidgets('SizedBox spacer between logo and title exists', (tester) async {
      await pumpSplash(tester);
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('Image assets', () {
    testWidgets('Logo.png asset is rendered', (tester) async {
      await pumpSplash(tester);
      expect(
        find.byWidgetPredicate((w) =>
            w is Image &&
            (w.image as AssetImage).assetName == 'assets/images/Logo.png'),
        findsOneWidget,
      );
    });

    testWidgets('Logo.png width is 100', (tester) async {
      await pumpSplash(tester);
      final img = tester.widgetList<Image>(find.byType(Image)).firstWhere(
            (i) => (i.image as AssetImage).assetName == 'assets/images/Logo.png',
          );
      expect(img.width, 100.0);
    });

    testWidgets('KUSAKU.png asset is rendered', (tester) async {
      await pumpSplash(tester);
      expect(
        find.byWidgetPredicate((w) =>
            w is Image &&
            (w.image as AssetImage).assetName == 'assets/images/KUSAKU.png'),
        findsOneWidget,
      );
    });

    testWidgets('KUSAKU.png width is 150', (tester) async {
      await pumpSplash(tester);
      final img = tester.widgetList<Image>(find.byType(Image)).firstWhere(
            (i) =>
                (i.image as AssetImage).assetName == 'assets/images/KUSAKU.png',
          );
      expect(img.width, 150.0);
    });

    testWidgets('Tagline image asset is rendered', (tester) async {
      await pumpSplash(tester);
      expect(
        find.byWidgetPredicate((w) =>
            w is Image &&
            (w.image as AssetImage).assetName ==
                'assets/images/Ayo Atur Pengeluaranmu!.png'),
        findsOneWidget,
      );
    });

    testWidgets('Tagline image width is 250', (tester) async {
      await pumpSplash(tester);
      final img = tester.widgetList<Image>(find.byType(Image)).firstWhere(
            (i) =>
                (i.image as AssetImage).assetName ==
                'assets/images/Ayo Atur Pengeluaranmu!.png',
          );
      expect(img.width, 250.0);
    });

    testWidgets('exactly three Image widgets are present', (tester) async {
      await pumpSplash(tester);
      expect(find.byType(Image), findsNWidgets(3));
    });
  });

  group('Animation widgets', () {
    testWidgets('ScaleTransition exists', (tester) async {
      await pumpSplash(tester);
      expect(find.byType(ScaleTransition), findsOneWidget);
    });

    testWidgets('RotationTransition exists', (tester) async {
      await pumpSplash(tester);
      expect(find.byType(RotationTransition), findsOneWidget);
    });

    testWidgets('FadeTransition exists', (tester) async {
      await pumpSplash(tester);
      expect(find.byType(FadeTransition), findsOneWidget);
    });

    testWidgets('RotationTransition wraps the Logo image', (tester) async {
      await pumpSplash(tester);
      expect(
        find.ancestor(
          of: find.byWidgetPredicate((w) =>
              w is Image &&
              (w.image as AssetImage).assetName == 'assets/images/Logo.png'),
          matching: find.byType(RotationTransition),
        ),
        findsOneWidget,
      );
    });

    testWidgets('FadeTransition wraps the tagline image', (tester) async {
      await pumpSplash(tester);
      expect(
        find.ancestor(
          of: find.byWidgetPredicate((w) =>
              w is Image &&
              (w.image as AssetImage).assetName ==
                  'assets/images/Ayo Atur Pengeluaranmu!.png'),
          matching: find.byType(FadeTransition),
        ),
        findsOneWidget,
      );
    });
  });


  group('Animation values over time', () {
    testWidgets('ScaleTransition starts at ≤ 0.5', (tester) async {
      await pumpSplash(tester);
      final st = tester.widget<ScaleTransition>(find.byType(ScaleTransition));
      expect(st.scale.value, lessThanOrEqualTo(0.5));
    });

    testWidgets('ScaleTransition reaches ~1.0 after 2500 ms', (tester) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(milliseconds: 2500));
      final st = tester.widget<ScaleTransition>(find.byType(ScaleTransition));
      expect(st.scale.value, closeTo(1.0, 0.05));
    });

    testWidgets('FadeTransition starts at opacity 0', (tester) async {
      await pumpSplash(tester);
      final ft = tester.widget<FadeTransition>(find.byType(FadeTransition));
      expect(ft.opacity.value, closeTo(0.0, 0.01));
    });

    testWidgets('FadeTransition reaches opacity 1 after 2500 ms', (tester) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(milliseconds: 2500));
      final ft = tester.widget<FadeTransition>(find.byType(FadeTransition));
      expect(ft.opacity.value, closeTo(1.0, 0.05));
    });

    testWidgets('RotationTransition starts animating after 1250 ms',
        (tester) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(milliseconds: 1250));
      final rt = tester.widget<RotationTransition>(
        find.byType(RotationTransition),
      );
      expect(rt.turns.isAnimating, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // 5. Padding
  // -------------------------------------------------------------------------
  group('Padding', () {
    testWidgets('tagline has bottom padding of 50', (tester) async {
      await pumpSplash(tester);
      final paddings = tester
          .widgetList<Padding>(find.byType(Padding))
          .where((p) => p.padding == const EdgeInsets.only(bottom: 50.0))
          .toList();
      expect(paddings, isNotEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // 6. Navigation
  // -------------------------------------------------------------------------
  group('Navigation', () {
    testWidgets('still shows SplashScreen before 4 s', (tester) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('navigates away exactly at 4 s', (tester) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.text('LoginScreen'), findsOneWidget);
    });

    testWidgets('uses pushReplacement (SplashScreen is not in back stack)',
        (tester) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      // Back button should NOT return to SplashScreen
      final NavigatorState nav = tester.state(find.byType(Navigator));
      expect(nav.canPop(), isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // 7. Lifecycle / dispose safety
  // -------------------------------------------------------------------------
  group('Lifecycle', () {
    testWidgets('no setState-after-dispose error when unmounted before timer',
        (tester) async {
      await pumpSplash(tester);
      // Unmount before the 4 s timer fires
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      // Advance time past both the 1250 ms and 4 s callbacks
      await tester.pump(const Duration(seconds: 5));
      // If no exception is thrown the test passes
    });

    testWidgets('rebuilds correctly after a hot-reload-style pump', (tester) async {
      await pumpSplash(tester);
      await tester.pump(const Duration(milliseconds: 500));
      // Pump the same widget again (simulates hot reload)
      await pumpSplash(tester);
      expect(find.byType(SplashScreen), findsOneWidget);
    });
  });
}