import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Prayer times are computed on device from an astronomical model.
///
/// This screen structurally cannot show a network error, because there is no
/// network call behind it.
class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer')),
      body: const Center(child: Text('Prayer times')),
    );
  }
}
