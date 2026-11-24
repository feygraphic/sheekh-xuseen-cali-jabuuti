import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Morning and Evening Adhkar JSON Database Verification', () {
    test('Verify assets/data/morning_adhkar.json format and content', () async {
      final jsonString = await rootBundle.loadString('assets/data/morning_adhkar.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      expect(data['category'], equals('morning'));
      expect(data['title'], equals('أذكار الصباح'));
      expect(data['duas'], isA<List>());

      final List<dynamic> duas = data['duas'];
      expect(duas.length, equals(23), reason: 'Hisnul Muslim Morning chapter has 23 canonical supplications');

      final ids = <String>{};
      for (int i = 0; i < duas.length; i++) {
        final dua = duas[i] as Map<String, dynamic>;
        
        // Check required fields
        expect(dua.containsKey('id'), isTrue);
        expect(dua.containsKey('title_ar'), isTrue);
        expect(dua.containsKey('title_so'), isTrue);
        expect(dua.containsKey('arabic_text'), isTrue);
        expect(dua.containsKey('somali_translation'), isTrue);
        expect(dua.containsKey('repetition_count'), isTrue);
        expect(dua.containsKey('reference'), isTrue);
        expect(dua.containsKey('audio_url'), isTrue);

        // Check values are non-empty
        final id = dua['id'] as String;
        expect(ids.contains(id), isFalse, reason: 'Duplicate ID found: $id');
        ids.add(id);

        expect((dua['title_ar'] as String).trim().isNotEmpty, isTrue);
        expect((dua['title_so'] as String).trim().isNotEmpty, isTrue);
        expect((dua['arabic_text'] as String).trim().isNotEmpty, isTrue);
        expect((dua['somali_translation'] as String).trim().isNotEmpty, isTrue);
        expect(dua['repetition_count'], isA<int>());
        expect(dua['repetition_count'] as int, greaterThan(0));
        expect((dua['reference'] as String).trim().isNotEmpty, isTrue);
        expect((dua['audio_url'] as String).trim().isNotEmpty, isTrue);
      }
    });

    test('Verify assets/data/evening_adhkar.json format and content', () async {
      final jsonString = await rootBundle.loadString('assets/data/evening_adhkar.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      expect(data['category'], equals('evening'));
      expect(data['title'], equals('أذكار المساء'));
      expect(data['duas'], isA<List>());

      final List<dynamic> duas = data['duas'];
      expect(duas.length, equals(22), reason: 'Hisnul Muslim Evening chapter has 22 canonical supplications');

      final ids = <String>{};
      for (int i = 0; i < duas.length; i++) {
        final dua = duas[i] as Map<String, dynamic>;

        // Check required fields
        expect(dua.containsKey('id'), isTrue);
        expect(dua.containsKey('title_ar'), isTrue);
        expect(dua.containsKey('title_so'), isTrue);
        expect(dua.containsKey('arabic_text'), isTrue);
        expect(dua.containsKey('somali_translation'), isTrue);
        expect(dua.containsKey('repetition_count'), isTrue);
        expect(dua.containsKey('reference'), isTrue);
        expect(dua.containsKey('audio_url'), isTrue);

        // Check values are non-empty
        final id = dua['id'] as String;
        expect(ids.contains(id), isFalse, reason: 'Duplicate ID found: $id');
        ids.add(id);

        expect((dua['title_ar'] as String).trim().isNotEmpty, isTrue);
        expect((dua['title_so'] as String).trim().isNotEmpty, isTrue);
        expect((dua['arabic_text'] as String).trim().isNotEmpty, isTrue);
        expect((dua['somali_translation'] as String).trim().isNotEmpty, isTrue);
        expect(dua['repetition_count'], isA<int>());
        expect(dua['repetition_count'] as int, greaterThan(0));
        expect((dua['reference'] as String).trim().isNotEmpty, isTrue);
        expect((dua['audio_url'] as String).trim().isNotEmpty, isTrue);
      }
    });
  });
}
