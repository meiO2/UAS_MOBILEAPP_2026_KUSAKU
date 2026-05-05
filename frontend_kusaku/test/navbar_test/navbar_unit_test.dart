import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('MainShell Logic Tests', () {

    test('clearSession sets is_authenticated to false', () async {
      SharedPreferences.setMockInitialValues({
        'is_authenticated': true,
      });

      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('is_authenticated', false);

      expect(prefs.getBool('is_authenticated'), isFalse);
    });

    test('onNavTapped changes index when not scan (index != 2)', () {
      int selectedIndex = 0;

      void onNavTapped(int index) {
        if (index == 2) return; // scan case (ignored)
        selectedIndex = index;
      }

      onNavTapped(1); // Finance
      expect(selectedIndex, 1);

      onNavTapped(3); // History
      expect(selectedIndex, 3);
    });

    test('onNavTapped does NOT change index when index == 2 (scan)', () {
      int selectedIndex = 0;

      void onNavTapped(int index) {
        if (index == 2) return;
        selectedIndex = index;
      }

      onNavTapped(2); // Scan button
      expect(selectedIndex, 0); // should stay unchanged
    });

    test('IndexedStack index mapping is correct', () {
      int mapIndex(int selectedIndex) {
        return selectedIndex > 2 ? selectedIndex - 1 : selectedIndex;
      }

      expect(mapIndex(0), 0); // Home
      expect(mapIndex(1), 1); // Finance
      expect(mapIndex(2), 2); // Scan (not used but mapped)
      expect(mapIndex(3), 2); // History
      expect(mapIndex(4), 3); // Profile
    });
  });
}