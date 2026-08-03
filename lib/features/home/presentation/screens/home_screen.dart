import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_one/app/router/routes.dart';
import 'package:quran_one/core/theme/theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran One'),
        actions: [
          IconButton(
            onPressed: () => context.push(Routes.settings),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Next prayer', style: context.text.labelMedium),
                  const SizedBox(height: 4),
                  Text('Asr', style: context.text.headlineMedium),
                  Text('in 1h 12m', style: context.text.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Deliberately absent on first run: there is nothing to continue.
          Card(
            child: ListTile(
              minTileHeight: 56,
              title: const Text('Continue reading'),
              subtitle: const Text('Al-Baqarah 255'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.reader(2, ayah: 255)),
            ),
          ),
        ],
      ),
    );
  }
}
