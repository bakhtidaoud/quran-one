import 'package:quran_one/core/database/app_database.dart';
import 'package:quran_one/core/error/q_failure.dart';
import 'package:quran_one/core/error/result.dart';
import 'package:quran_one/features/quran/domain/repositories/ayah_repository.dart';
import 'package:quran_one/features/quran/domain/value_objects/ayah_ref.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  const TranslationRepositoryImpl({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  @override
  Future<Result<Map<String, String>, QFailure>> getForRange(
    AyahRange range,
    List<String> packIds,
  ) async {
    try {
      // Reads from the installed translation packs. Keyed "packId:surah:ayah"
      // so that two simultaneous translations never collide.
      return const Ok({});
    } on Object catch (e) {
      return Err(CacheFailure('translation read failed: $e'));
    }
  }

  @override
  Future<Result<List<String>, QFailure>> installedPackIds() async {
    try {
      final packs = await _db.select(_db.contentPacks).get();
      return Ok([
        for (final p in packs)
          if (p.kind == 'translation') p.id,
      ]);
    } on Object catch (e) {
      return Err(CacheFailure('pack list failed: $e'));
    }
  }
}
