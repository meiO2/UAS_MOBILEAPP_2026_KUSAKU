import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_kusaku/Services/chat_service.dart';

void main() {
  group('ChatResponse.fromJson', () {
    test('parses reply, type, and data correctly', () {
      final json = {
        'reply': 'Halo!',
        'type': 'budget_suggestion',
        'data': {'Makanan': 40.0},
      };
      final response = ChatResponse.fromJson(json);
      expect(response.reply, 'Halo!');
      expect(response.type, 'budget_suggestion');
      expect(response.data, {'Makanan': 40.0});
    });

    test('defaults reply to empty string when missing', () {
      final response = ChatResponse.fromJson({});
      expect(response.reply, '');
    });

    test('defaults type to "text" when missing', () {
      final response = ChatResponse.fromJson({});
      expect(response.type, 'text');
    });

    test('data is null when not provided', () {
      final response = ChatResponse.fromJson({'reply': 'Hi', 'type': 'text'});
      expect(response.data, isNull);
    });

    test('parses data with multiple categories', () {
      final response = ChatResponse.fromJson({
        'reply': 'Ini budget kamu',
        'type': 'budget_suggestion',
        'data': {'Makanan': 30.0, 'Transportasi': 20.0, 'Hiburan': 10.0},
      });
      expect(response.data!['Makanan'], 30.0);
      expect(response.data!['Transportasi'], 20.0);
    });

    test('handles type other than budget_suggestion', () {
      final response =
          ChatResponse.fromJson({'reply': 'OK', 'type': 'text'});
      expect(response.type, 'text');
      expect(response.data, isNull);
    });
  });

  group('updatePercentage guard logic', () {
    bool canUpdate(
      String cat,
      double newVal,
      Map<String, double> percentages,
      Map<String, bool> enabled,
    ) {
      final total = percentages.entries
          .where((e) => e.key != cat && (enabled[e.key] ?? false))
          .fold(0.0, (sum, e) => sum + e.value);
      return total + newVal <= 100;
    }

    test('allows update when total stays at 100', () {
      final pct = {'Makanan': 60.0, 'Transport': 30.0};
      final ena = {'Makanan': true, 'Transport': true};
      // Updating Makanan to 70 → 70 + 30 = 100 ✓
      expect(canUpdate('Makanan', 70, pct, ena), isTrue);
    });

    test('blocks update when total would exceed 100', () {
      final pct = {'Makanan': 60.0, 'Transport': 30.0};
      final ena = {'Makanan': true, 'Transport': true};
      // Updating Makanan to 80 → 80 + 30 = 110 ✗
      expect(canUpdate('Makanan', 80, pct, ena), isFalse);
    });

    test('ignores disabled categories in total', () {
      final pct = {'Makanan': 60.0, 'Transport': 30.0};
      final ena = {'Makanan': true, 'Transport': false};
      // Transport disabled, so only 0 counted → 80 + 0 = 80 ✓
      expect(canUpdate('Makanan', 80, pct, ena), isTrue);
    });

    test('allows 0 percentage update always', () {
      final pct = {'Makanan': 99.0, 'Transport': 0.0};
      final ena = {'Makanan': true, 'Transport': true};
      expect(canUpdate('Transport', 0, pct, ena), isTrue);
    });

    test('allows update when only one category exists', () {
      final pct = {'Makanan': 50.0};
      final ena = {'Makanan': true};
      expect(canUpdate('Makanan', 100, pct, ena), isTrue);
    });
  });

  // ── _applyBudgetSuggestion logic ───────────────────────────────────────────
  group('applyBudgetSuggestion logic', () {
    // Mirror of _applyBudgetSuggestion
    void applyBudget(
      Map<String, dynamic> data,
      List<String> order,
      Map<String, double> percentages,
      Map<String, bool> enabled,
    ) {
      for (var category in data.keys) {
        final pct = (data[category] as num).toDouble();
        if (!order.contains(category)) order.add(category);
        percentages[category] = pct;
        enabled[category] = pct > 0;
      }
    }

    test('adds new categories from budget data', () {
      final order = <String>[];
      final pct = <String, double>{};
      final ena = <String, bool>{};

      applyBudget({'Makanan': 40.0, 'Transport': 20.0}, order, pct, ena);

      expect(order, containsAll(['Makanan', 'Transport']));
    });

    test('sets percentage correctly', () {
      final order = <String>[];
      final pct = <String, double>{};
      final ena = <String, bool>{};

      applyBudget({'Makanan': 40.0}, order, pct, ena);
      expect(pct['Makanan'], 40.0);
    });

    test('enables category when percentage > 0', () {
      final order = <String>[];
      final pct = <String, double>{};
      final ena = <String, bool>{};

      applyBudget({'Makanan': 10.0}, order, pct, ena);
      expect(ena['Makanan'], isTrue);
    });

    test('disables category when percentage is 0', () {
      final order = <String>[];
      final pct = <String, double>{};
      final ena = <String, bool>{};

      applyBudget({'Hiburan': 0.0}, order, pct, ena);
      expect(ena['Hiburan'], isFalse);
    });

    test('does not add duplicate category to order', () {
      final order = ['Makanan'];
      final pct = {'Makanan': 30.0};
      final ena = {'Makanan': true};

      applyBudget({'Makanan': 50.0}, order, pct, ena);
      expect(order.where((e) => e == 'Makanan').length, 1);
      expect(pct['Makanan'], 50.0);
    });
  });

  // ── Duplicate category detection ───────────────────────────────────────────
  group('Duplicate category detection', () {
    bool isDuplicate(List<String> existing, String newName) {
      return existing.any((k) => k.toLowerCase() == newName.toLowerCase());
    }

    test('detects exact duplicate', () {
      expect(isDuplicate(['Makanan', 'Transport'], 'Makanan'), isTrue);
    });

    test('detects case-insensitive duplicate', () {
      expect(isDuplicate(['makanan'], 'MAKANAN'), isTrue);
    });

    test('returns false for new unique category', () {
      expect(isDuplicate(['Makanan', 'Transport'], 'Hiburan'), isFalse);
    });

    test('returns false for empty list', () {
      expect(isDuplicate([], 'Makanan'), isFalse);
    });
  });

  // ── Send message guard ─────────────────────────────────────────────────────
  group('Send message guard', () {
    bool shouldSend(String text) => text.trim().isNotEmpty;

    test('does not send empty message', () {
      expect(shouldSend(''), isFalse);
    });

    test('does not send whitespace-only message', () {
      expect(shouldSend('   '), isFalse);
    });

    test('sends valid message', () {
      expect(shouldSend('Halo!'), isTrue);
    });
  });

  // ── getCategories response parsing ─────────────────────────────────────────
  group('getCategories response parsing', () {
    List<Map<String, dynamic>> parseCategories(List raw) {
      return raw.map<Map<String, dynamic>>((item) => {
            'id': item['id'],
            'name': item['name'],
            'percentage': (item['percentage'] as num).toDouble(),
            'enabled': item['enabled'] ?? true,
          }).toList();
    }

    test('parses single category correctly', () {
      final raw = [
        {'id': 1, 'name': 'Makanan', 'percentage': 40, 'enabled': true}
      ];
      final result = parseCategories(raw);
      expect(result.first['name'], 'Makanan');
      expect(result.first['percentage'], 40.0);
      expect(result.first['enabled'], isTrue);
    });

    test('defaults enabled to true when missing', () {
      final raw = [
        {'id': 2, 'name': 'Transport', 'percentage': 20}
      ];
      final result = parseCategories(raw);
      expect(result.first['enabled'], isTrue);
    });

    test('converts int percentage to double', () {
      final raw = [
        {'id': 3, 'name': 'Hiburan', 'percentage': 15, 'enabled': false}
      ];
      final result = parseCategories(raw);
      expect(result.first['percentage'], isA<double>());
    });

    test('parses multiple categories', () {
      final raw = [
        {'id': 1, 'name': 'A', 'percentage': 10, 'enabled': true},
        {'id': 2, 'name': 'B', 'percentage': 20, 'enabled': false},
      ];
      final result = parseCategories(raw);
      expect(result.length, 2);
    });
  });
}