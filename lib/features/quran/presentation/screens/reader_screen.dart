import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_one/core/error/q_failure.dart';
import 'package:quran_one/core/theme/theme.dart';
import 'package:quran_one/features/quran/domain/entities/ayah.dart';
import 'package:quran_one/features/quran/domain/value_objects/ayah_ref.dart';
import 'package:quran_one/features/quran/presentation/controllers/reader_controller.dart';
import 'package:quran_one/features/quran/presentation/widgets/ayah_view.dart';

/// Full-bleed reading surface. No bottom navigation, by design.
class ReaderScreen extends ConsumerWidget {
  const ReaderScreen({required this.surahId, this.initialAyah, super.key});

  final int surahId;
  final int? initialAyah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(surahIndexProvider).valueOrNull;
    final surah = index?.where((s) => s.number == surahId).firstOrNull;

    if (surah == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final range = AyahRange.surah(surahId, surah.ayahCount);
    final state = ref.watch(readerControllerProvider(range));
    final reading = context.reading;

    return Scaffold(
      backgroundColor: reading.canvas,
      appBar: AppBar(
        backgroundColor: reading.canvas,
        toolbarHeight: 56,
        title: Text(surah.latinName),
      ),
      body: state.when(
        data: (ayat) => ListView.builder(
          // Measure: the reading column never exceeds 720dp regardless of
          // window width. Long lines destroy reading rhythm.
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          itemCount: ayat.length,
          itemBuilder: (context, i) => AyahView(annotated: ayat[i]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ReaderError(failure: e),
      ),
    );
  }
}

/// Switches exhaustively on the sealed failure type. A missing content pack
/// is not "something went wrong" - it is a download button.
class _ReaderError extends StatelessWidget {
  const _ReaderError({required this.failure});

  final Object failure;

  @override
  Widget build(BuildContext context) {
    final (title, body, action) = switch (failure) {
      ContentPackMissingFailure() => (
          'Quran text not installed',
          'Download the Uthmani text once and read it forever offline.',
          'Download',
        ),
      CacheFailure() => (
          'Could not open your library',
          'Restarting the app usually resolves this.',
          'Retry',
        ),
      _ => ('Something failed', '$failure', 'Retry'),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: context.text.titleLarge),
            const SizedBox(height: 8),
            Text(
              body,
              style: context.text.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: () {}, child: Text(action)),
          ],
        ),
      ),
    );
  }
}
