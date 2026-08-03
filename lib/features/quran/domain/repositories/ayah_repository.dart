import 'package:quran_one/core/error/q_failure.dart';
import 'package:quran_one/core/error/result.dart';
import 'package:quran_one/features/quran/domain/entities/ayah.dart';
import 'package:quran_one/features/quran/domain/value_objects/ayah_ref.dart';

/// The contract. The implementation lives in data/ and is bound in
/// app/di.dart, which is the only file that knows both sides exist.
abstract interface class AyahRepository {
  Future<Result<List<Ayah>, QFailure>> getRange(AyahRange range);

  Future<Result<List<Ayah>, QFailure>> getPage(int page);

  Future<Result<List<Surah>, QFailure>> surahIndex();

  Stream<List<Ayah>> watchRange(AyahRange range);
}

abstract interface class TranslationRepository {
  /// Returns translation text keyed by ayah reference string.
  Future<Result<Map<String, String>, QFailure>> getForRange(
    AyahRange range,
    List<String> packIds,
  );

  Future<Result<List<String>, QFailure>> installedPackIds();
}

abstract interface class ReadingPositionRepository {
  Future<AyahRef?> lastPosition(String mode);

  Future<void> save(String mode, AyahRef ref, {int? page});
}
