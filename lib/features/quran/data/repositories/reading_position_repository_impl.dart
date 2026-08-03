import 'package:drift/drift.dart';
import 'package:quran_one/core/database/app_database.dart';
import 'package:quran_one/features/quran/domain/repositories/ayah_repository.dart';
import 'package:quran_one/features/quran/domain/value_objects/ayah_ref.dart';

/// One row per reading mode, so that mushaf position and translation-list
/// position do not overwrite each other.
class ReadingPositionRepositoryImpl implements ReadingPositionRepository {
  const ReadingPositionRepositoryImpl({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  @override
  Future<AyahRef?> lastPosition(String mode) async {
    final row = await (_db.select(_db.readingPositions)
          ..where((t) => t.mode.equals(mode)))
        .getSingleOrNull();
    if (row == null) return null;
    return AyahRef(row.surah, row.ayah);
  }

  @override
  Future<void> save(String mode, AyahRef ref, {int? page}) =>
      _db.into(_db.readingPositions).insertOnConflictUpdate(
            ReadingPositionsCompanion.insert(
              mode: mode,
              surah: ref.surah,
              ayah: ref.number,
              page: Value(page),
              updatedAt: DateTime.now(),
            ),
          );
}
