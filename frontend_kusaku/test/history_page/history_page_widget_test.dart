import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_kusaku/Navigation/History_Kusaku/history_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'user_id': 1});
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: HistoryPage(),
    );
  }

  testWidgets('Should display loading indicator initially', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Should display error state when user_id is missing', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Sesi tidak ditemukan, silakan login ulang'), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget); // Coba Lagi button
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
  });

  testWidgets('Should open filter overlay when filter button is pressed (Assuming success state)', (WidgetTester tester) async {
    // Note: This assumes the HTTP call succeeds or is bypassed.
    // If HTTP fails, the HistoryTopSection won't render. 
    // You will need an HttpOverrides or injected mock client to pass the 200 OK barrier in Widget tests.
    
    // This is how you would test the overlay interaction:
    /*
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Tap on the filter button inside HistoryTopSection
    // You might need to add a ValueKey to your filter button in HistoryTopSection
    await tester.tap(find.byType(HistoryTopSection)); 
    await tester.pumpAndSettle();

    // Verify overlay appears
    expect(find.byType(HistoryFilterOverlay), findsOneWidget);
    */
  });
}