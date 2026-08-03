import 'package:quran_one/features/quran/domain/value_objects/ayah_ref.dart';

/// Records a reading position from dwell, not from scroll offset.
///
/// An ayah becomes the stored position when it has been the topmost
/// fully visible ayah continuously for [dwell]. A fling passes over two
/// hundred verses in under a second and must commit none of them.
///
/// This is the single most important behaviour in the reader. If the
/// stored position is wrong then the resume card, the second most
/// valuable element in the whole app, is actively harmful: it takes the
/// user somewhere they have never read.
///
/// Deliberately a plain class rather than a Notifier. It is driven from
/// a scroll listener at display refresh rate and must not touch the
/// provider graph on every frame.
class ReadingPositionRecorder {
  ReadingPositionRecorder(this._save);

  /// How long an ayah must stay topmost before it counts as read.
  static const dwell = Duration(seconds: 3);

  /// Writes are coalesced. A write per verse would mean a database
  /// transaction and an outbox row for every line of a surah.
  static const minWriteInterval = Duration(seconds: 30);

  final Future<void> Function(AyahRef ref, DateTime at) _save;

  AyahRef? _candidate;
  DateTime? _candidateSince;
  DateTime? _lastWrite;

  AyahRef? get candidate => _candidate;

  /// Call with the topmost fully visible ayah on every scroll frame.
  void onVisible(AyahRef ref, DateTime now) {
    if (ref != _candidate) {
      _candidate = ref;
      _candidateSince = now;
      return;
    }

    if (now.difference(_candidateSince!) < dwell) return;

    final last = _lastWrite;
    if (last != null && now.difference(last) < minWriteInterval) return;

    _lastWrite = now;
    _save(ref, now);
  }

  /// Commit the current candidate even if it has not reached the dwell
  /// threshold. Backgrounding is itself a strong signal that this is
  /// where the user stopped, and it is the moment most likely to be
  /// followed by a resume.
  Future<void> flush(DateTime now) async {
    final candidate = _candidate;
    if (candidate == null) return;
    _lastWrite = now;
    await _save(candidate, now);
  }

  /// Note for whoever receives the first bug report about this:
  ///
  /// "I scrolled fast, closed the app, and it resumed two screens
  /// back" is correct behaviour, not a defect. Do not fix it by
  /// storing the raw scroll offset. The sync rule that pairs with it
  /// is furthest wins, never latest wins.
  void reset() {
    _candidate = null;
    _candidateSince = null;
  }
}
