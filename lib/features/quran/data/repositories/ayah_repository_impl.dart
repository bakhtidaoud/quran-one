import 'package:quran_one/core/error/q_failure.dart';
import 'package:quran_one/core/error/result.dart';
import 'package:quran_one/features/quran/data/sources/ayah_local_source.dart';
import 'package:quran_one/features/quran/domain/entities/ayah.dart';
import 'package:quran_one/features/quran/domain/repositories/ayah_repository.dart';
import 'package:quran_one/features/quran/domain/value_objects/ayah_ref.dart';

/// Local-first, and local-only for scripture.
///
/// There is deliberately no remote fallback here. If the content pack is
/// missing the user is offered a download; the app never silently fetches
/// Quranic text over the network, because unverified scripture is worse
/// than absent scripture.
class AyahRepositoryImpl implements AyahRepository {
  const AyahRepositoryImpl({required AyahLocalSource local}) : _local = local;

  final AyahLocalSource _local;

  @override
  Future<Result<List<Ayah>, QFailure>> getRange(AyahRange range) async {
    try {
      final rows = await _local.getRange(
        range.start.surah,
        range.start.number,
        range.end.surah,
        range.end.number,
      );
      if (rows.isEmpty) return const Err(ContentPackMissingFailure('quran.uthmani'));
      return Ok(rows);
    } on Object catch (e) {
      return Err(CacheFailure('ayah range read failed: $e'));
    }
  }

  @override
  Future<Result<List<Ayah>, QFailure>> getPage(int page) async {
    try {
      final rows = await _local.getRange(1, 1, 114, 6);
      final filtered = rows.where((a) => a.page == page).toList();
      if (filtered.isEmpty) {
        return const Err(ContentPackMissingFailure('quran.uthmani'));
      }
      return Ok(filtered);
    } on Object catch (e) {
      return Err(CacheFailure('page read failed: $e'));
    }
  }

  @override
  Future<Result<List<Surah>, QFailure>> surahIndex() async {
    try {
      return Ok(await _local.surahIndex());
    } on Object catch (e) {
      return Err(CacheFailure('surah index read failed: $e'));
    }
  }

  @override
  Stream<List<Ayah>> watchRange(AyahRange range) async* {
    final result = await getRange(range);
    if (result case Ok(:final value)) yield value;
  }
}
