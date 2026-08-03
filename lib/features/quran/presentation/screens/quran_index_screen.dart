import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_one/app/router/routes.dart';
import 'package:quran_one/core/theme/theme.dart';
import 'package:quran_one/features/quran/domain/entities/ayah.dart';
import 'package:quran_one/features/quran/presentation/controllers/reader_controller.dart';

class QuranIndexScreen extends ConsumerWidget {
  const QuranIndexScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(surahIndexProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Read')),
      body: index.when(
        data: (surahs) => ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: surahs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, i) => _SurahTile(surah: surahs[i]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

/// Extracted to a class rather than a _buildTile method, so that it gets its
/// own element and rebuilds independently.
class _SurahTile extends StatelessWidget {
  const _SurahTile({required this.surah});

  final Surah surah;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // 48dp minimum touch target, everywhere, no exceptions.
      minTileHeight: 56,
      leading: SizedBox(
        width: 36,
        child: Center(
          child: Text('${surah.number}', style: context.text.labelLarge),
        ),
      ),
      title: Text(surah.latinName, style: context.text.titleMedium),
      subtitle: Text(
        '${surah.englishName} - ${surah.ayahCount} ayat',
        style: context.text.bodySmall,
      ),
      trailing: Text(
        surah.arabicName,
        style: context.reading.mushaf.copyWith(fontSize: 20),
        textDirection: TextDirection.rtl,
      ),
      onTap: () => context.push(Routes.reader(surah.number)),
    );
  }
}
