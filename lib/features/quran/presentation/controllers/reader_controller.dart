import 'dart:async';

import 'package:quran_one/app/di.dart';
import 'package:quran_one/core/error/result.dart';
import 'package:quran_one/features/quran/domain/entities/ayah.dart';
import 'package:quran_one/features/quran/domain/value_objects/ayah_ref.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reader_controller.g.dart';

/// Reader state for one range.
///
/// autoDispose by default, with an explicit five-minute keepAlive: laying
/// out a page of Uthmani script is expensive and users leave and return
/// constantly.
@riverpod
class ReaderController extends _$ReaderController {
  @override
  Future<List<AnnotatedAyah>> build(AyahRange range) async {
    final link = ref.keepAlive();
    final timer = Timer(const Duration(minutes: 5), link.close);
    ref.onDispose(timer.cancel);

    final result = await ref.watch(getAnnotatedRangeProvider)(range);

    return switch (result) {
      Ok(:final value) => value,
      // Rethrowing puts the typed failure into AsyncValue.error, where the
      // screen switches on it exhaustively.
      Err(:final error) => throw error,
    };
  }

  Future<void> savePosition(AyahRef ref_) async {
    await ref.read(readingPositionRepositoryProvider).save('mushaf', ref_);
  }
}

/// The 114-entry surah index. keepAlive because every screen needs it and it
/// never changes.
@Riverpod(keepAlive: true)
Future<List<Surah>> surahIndex(Ref ref) async {
  final result = await ref.watch(ayahRepositoryProvider).surahIndex();
  return switch (result) {
    Ok(:final value) => value,
    Err(:final error) => throw error,
  };
}
