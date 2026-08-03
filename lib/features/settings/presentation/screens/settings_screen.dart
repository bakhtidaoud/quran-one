import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_one/core/theme/theme.dart';
import 'package:quran_one/presentation/theme/theme_controller.dart';

/// No Save button. Settings apply on change, because a Save button on a
/// preferences screen is a bug the user has to work around.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);
    final sizes = ref.watch(readingSizeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Appearance'),
          for (final m in QThemeMode.values)
            RadioListTile<QThemeMode>(
              value: m,
              groupValue: mode,
              onChanged: (v) => v == null
                  ? null
                  : ref.read(themeControllerProvider.notifier).setMode(v),
              title: Text(switch (m) {
                QThemeMode.light => 'Light',
                QThemeMode.dark => 'Dark',
                QThemeMode.amoled => 'AMOLED black',
              }),
            ),
          const _SectionHeader('Reading'),
          ListTile(
            title: const Text('Arabic size'),
            subtitle: Slider(
              value: sizes.mushaf,
              min: 18,
              max: 48,
              divisions: 30,
              label: sizes.mushaf.round().toString(),
              onChanged: (v) =>
                  ref.read(readingSizeControllerProvider.notifier).setMushaf(v),
            ),
          ),
          ListTile(
            title: const Text('Translation size'),
            subtitle: Slider(
              value: sizes.translation,
              min: 14,
              max: 32,
              divisions: 18,
              label: sizes.translation.round().toString(),
              onChanged: (v) => ref
                  .read(readingSizeControllerProvider.notifier)
                  .setTranslation(v),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          label,
          style: context.text.labelLarge?.copyWith(
            color: context.colors.primary,
          ),
        ),
      );
}
