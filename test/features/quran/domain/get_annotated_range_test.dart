import 'package:flutter_test/flutter_test.dart';
import 'package:quran_one/core/error/q_failure.dart';
import 'package:quran_one/core/error/result.dart';
import 'package:quran_one/features/quran/domain/entities/ayah.dart';
import 'package:quran_one/features/quran/domain/repositories/ayah_repository.dart';
import 'package:quran_one/features/quran/domain/usecases/get_annotated_range.dart';
import 'package:quran_one/features/quran/domain/value_objects/ayah_ref.dart';

/// Hand-written fakes, not mocks. They read better, they survive interface
/// changes as a compile error, and they can hold state across calls.
class _FakeAyahRepo implements AyahRepository {
  _FakeAyahRepo({this.failure});

  final QFailure? failure;

  @override
  Future<Result<List<Ayah>, QFailure>> getRange(AyahRange range) async {
    if (failure != null) return Err(failure!);
    return Ok([
      Ayah(ref: AyahRef(2, 255), arabic: 'ayat al-kursi', juz: 3, page: 42),
    ]);
  }

  @override
  Future<Result<List<Ayah>, QFailure>> getPage(int page) async => const Ok([]);

  @override
  Future<Result<List<Surah>, QFailure>> surahIndex() async => const Ok([]);

  @override
  Stream<List<Ayah>> watchRange(AyahRange range) => const Stream.empty();
}

class _FakeTranslationRepo implements TranslationRepository {
  _FakeTranslationRepo({this.packs = const [], this.texts = const {}});

  final List<String> packs;
  final Map<String, String> texts;

  @override
  Future<Result<Map<String, String>, QFailure>> getForRange(
    AyahRange range,
    List<String> packIds,
  ) async =>
      Ok(texts);

  @override
  Future<Result<List<String>, QFailure>> installedPackIds() async => Ok(packs);
}

void main() {
  final range = AyahRange(AyahRef(2, 255), AyahRef(2, 255));

  test('returns bare ayat when no translation pack is installed', () async {
    final useCase = GetAnnotatedRange(_FakeAyahRepo(), _FakeTranslationRepo());

    final result = await useCase(range);

    // No packs installed is a normal state, not a failure. The Arabic still
    // renders, which is the part that matters.
    expect(result.isOk, isTrue);
    expect(result.valueOrNull!.single.translations, isEmpty);
  });

  test('attaches every installed translation to its ayah', () async {
    final useCase = GetAnnotatedRange(
      _FakeAyahRepo(),
      _FakeTranslationRepo(
        packs: ['sahih', 'pickthall'],
        texts: {
          'sahih:2:255': 'Allah - there is no deity except Him',
          'pickthall:2:255': 'Allah! There is no god save Him',
        },
      ),
    );

    final result = await useCase(range);

    expect(result.valueOrNull!.single.translations.length, 2);
  });

  test('propagates a missing content pack unchanged', () async {
    final useCase = GetAnnotatedRange(
      _FakeAyahRepo(failure: const ContentPackMissingFailure('quran.uthmani')),
      _FakeTranslationRepo(),
    );

    final result = await useCase(range);

    // The reader shows a download button, not "something went wrong".
    expect(result.errorOrNull, isA<ContentPackMissingFailure>());
  });
}
