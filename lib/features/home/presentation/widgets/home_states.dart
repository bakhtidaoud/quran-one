import 'package:flutter/material.dart';
import 'package:quran_one/core/theme/theme_context.dart';

/// Loading, offline and degraded presentation for Home.
///
/// The governing rule: Home never shows a full screen spinner. Every
/// value it needs is either already on device (reading position, wird,
/// due cards, hijri date) or computable on device (prayer times, from
/// stored coordinates). A spinner on this screen means something has
/// been architected wrong, not that the network is slow.
enum HomeDataState {
  /// Everything resolved from local storage. The normal case.
  ready,

  /// First frame after a cold start, before the database task has
  /// completed. Lasts a handful of frames.
  warming,

  /// Prayer times could not be computed because no coordinates have
  /// ever been stored. The only genuinely empty state on Home.
  locationUnknown,

  /// Coordinates are stale enough that the times may be wrong, for
  /// example after a flight. Times still render.
  locationStale,
}

/// Placeholder for the prayer card during [HomeDataState.warming].
///
/// It reserves the exact height of the real card. A skeleton that is a
/// different size than its content causes the whole screen to jump on
/// resolve, which reads as slower than a longer wait would have.
class QPrayerCardSkeleton extends StatelessWidget {
  const QPrayerCardSkeleton({super.key});

  /// Measured from QPrayerCard with the elapsed line present.
  static const height = 168.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // Announcing "loading" here would interrupt for something that
      // resolves in under a frame budget on any device we support.
      excludeSemantics: true,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: context.colors.primaryContainer.withValues(alpha: 0.45),
          borderRadius: context.shape.card,
        ),
      ),
    );
  }
}

/// The only empty state on Home worth designing.
///
/// It asks for one thing and explains the trade, because the answer to
/// "why does a Quran app want my location" has to be on the screen that
/// asks, not in a settings page nobody opens.
class QLocationNeededCard extends StatelessWidget {
  const QLocationNeededCard({
    required this.onGrant,
    required this.onEnterCity,
    super.key,
  });

  final VoidCallback onGrant;

  /// Always offered. A user who refuses location permission must still
  /// get prayer times, and a manual city is a complete substitute.
  final VoidCallback onEnterCity;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prayer times need a location',
                style: context.text.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Times are calculated on your device. Your location is '
              'never sent to us.',
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton(onPressed: onGrant, child: const Text('Allow')),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onEnterCity,
                  child: const Text('Enter a city'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Offline is not an error on this screen and must not look like one.
///
/// Prayer times, the reading position, the wird and the due count are
/// all local. Nothing above the fold degrades. The only honest signal
/// is that sync has paused, and it belongs in the app bar as a quiet
/// icon, not as a banner that displaces content.
class QSyncPausedIndicator extends StatelessWidget {
  const QSyncPausedIndicator({required this.pendingCount, super.key});

  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    if (pendingCount == 0) return const SizedBox.shrink();

    return Semantics(
      label: 'Sync paused, $pendingCount changes waiting',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 4),
        child: Icon(
          Icons.cloud_off_outlined,
          size: 20,
          color: context.colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Tier 3 content is the only thing on Home that can fail to load, and
/// the correct treatment for a missing hadith of the day is to render
/// nothing at all rather than an apology.
class QQuietFailure extends StatelessWidget {
  const QQuietFailure({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
