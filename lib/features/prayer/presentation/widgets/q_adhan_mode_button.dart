import 'package:flutter/material.dart';
import 'package:quran_one/features/home/presentation/controllers/countdown.dart'
    show Prayer;
import 'package:quran_one/features/profile/domain/entities/account_profile.dart'
    show AthanMode;

/// Per prayer notification mode for the next prayer.
///
/// The common design here is a speaker icon that plays the adhan on
/// demand. That is a media control masquerading as a worship control,
/// and it is the wrong affordance: nobody wants to hear Asr called at
/// 14:03 from their pocket. What they want is to decide whether it will
/// be called at 16:42, and how.
///
/// Cycles off -> silent -> athan.
class QAdhanModeButton extends StatelessWidget {
  const QAdhanModeButton({
    required this.prayer,
    required this.mode,
    required this.onChanged,
    required this.willBeSuppressed,
    super.key,
  });

  final Prayer prayer;
  final AthanMode mode;
  final ValueChanged<AthanMode> onChanged;

  /// True when the operating system will silence the notification
  /// regardless of this setting: Do Not Disturb or an OEM battery
  /// manager on Android, a Focus mode or the ringer switch on iOS.
  ///
  /// This is risk AR-2, and it is the most damaging lie this control
  /// could tell. Showing a confident "athan on" state while the device
  /// will stay silent means somebody misses Fajr and blames the app,
  /// correctly.
  final bool willBeSuppressed;

  bool get _isMisleading => willBeSuppressed && mode == AthanMode.athan;

  @override
  Widget build(BuildContext context) {
    // Prayer names are never translated, in any locale, including here.
    final name = prayer.name;
    final base = switch (mode) {
      AthanMode.off => 'Athan off for $name',
      AthanMode.silent => 'Silent notification for $name',
      AthanMode.athan => 'Athan will play for $name',
    };

    return Semantics(
      button: true,
      // The suppression warning goes in the label, not only in a small
      // crossed out badge. A user who cannot see the badge is exactly
      // the user who most needs to know the adhan will not sound.
      label: _isMisleading
          ? '$base, but your device is set to silent'
          : base,
      excludeSemantics: true,
      child: IconButton(
        // 48dp is the floor from the accessibility canon, not a target.
        constraints: const BoxConstraints.tightFor(width: 48, height: 48),
        onPressed: () => onChanged(nextMode(mode)),
        icon: Icon(_icon),
      ),
    );
  }

  IconData get _icon {
    if (_isMisleading) return Icons.notifications_off_outlined;
    return switch (mode) {
      AthanMode.off => Icons.notifications_none,
      AthanMode.silent => Icons.notifications_active_outlined,
      AthanMode.athan => Icons.volume_up_outlined,
    };
  }

  @visibleForTesting
  static AthanMode nextMode(AthanMode current) => switch (current) {
        AthanMode.off => AthanMode.silent,
        AthanMode.silent => AthanMode.athan,
        AthanMode.athan => AthanMode.off,
      };
}
