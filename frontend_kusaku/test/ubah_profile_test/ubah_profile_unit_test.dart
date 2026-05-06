import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Profile data extraction', () {
    Map<String, String> extract(Map<String, dynamic> data) {
      return {
        'name': data['username'] ?? '',
        'phone': data['phone_number'] ?? '',
        'email': data['email'] ?? '',
      };
    }

    test('normal data', () {
      final result = extract({
        'username': 'Budi',
        'phone_number': '08123',
        'email': 'budi@mail.com',
      });

      expect(result['name'], 'Budi');
      expect(result['phone'], '08123');
      expect(result['email'], 'budi@mail.com');
    });

    test('null fields become empty', () {
      final result = extract({
        'username': null,
        'phone_number': null,
        'email': null,
      });

      expect(result['name'], '');
      expect(result['phone'], '');
      expect(result['email'], '');
    });
  });

  group('Validation logic', () {
    bool isValidName(String name) => name.trim().isNotEmpty;

    test('valid name', () {
      expect(isValidName('Budi'), true);
    });

    test('empty name', () {
      expect(isValidName('   '), false);
    });
  });
}