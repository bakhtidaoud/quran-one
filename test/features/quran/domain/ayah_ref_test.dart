import 'package:flutter_test/flutter_test.dart';
import 'package:quran_one/features/quran/domain/value_objects/ayah_ref.dart';

/// Pure Dart. No container, no widgets, no mocks.
void main() {
  group('AyahRef', () {
    test('rejects surah numbers outside 1-114', () {
      expect(() => AyahRef(0, 1), throwsArgumentError);
      expect(() => AyahRef(115, 1), throwsArgumentError);
      expect(() => AyahRef(1, 0), throwsArgumentError);
    });

    test('formats as surah:ayah', () {
      expect(AyahRef(2, 255).toString(), '2:255');
    });

    test('tryParse returns null on malformed input rather than throwing', () {
      // This runs on deep-link input, which is untrusted.
      expect(AyahRef.tryParse('nonsense'), isNull);
      expect(AyahRef.tryParse('2:'), isNull);
      expect(AyahRef.tryParse('115:1'), isNull);
      expect(AyahRef.tryParse('2:255'), AyahRef(2, 255));
    });

    test('has value equality so it is safe as a family parameter', () {
      expect(AyahRef(2, 255), AyahRef(2, 255));
      expect(AyahRef(2, 255).hashCode, AyahRef(2, 255).hashCode);
    });

    test('sorts by surah then ayah', () {
      final refs = [AyahRef(2, 10), AyahRef(1, 7), AyahRef(2, 1)]..sort();
      expect(refs.map((r) => r.toString()), ['1:7', '2:1', '2:10']);
    });
  });

  group('AyahRange', () {
    test('has value equality', () {
      final a = AyahRange(AyahRef(2, 1), AyahRef(2, 5));
      final b = AyahRange(AyahRef(2, 1), AyahRef(2, 5));
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });
}
