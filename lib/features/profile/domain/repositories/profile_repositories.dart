import 'package:quran_one/core/error/q_failure.dart';
import 'package:quran_one/core/error/result.dart';
import 'package:quran_one/features/profile/domain/entities/account_profile.dart';
import 'package:quran_one/features/profile/domain/entities/device_preferences.dart';

/// Three repositories rather than one, because the three tiers have
/// different owners, different residences and different failure modes.

abstract interface class DevicePreferencesRepository {
  /// Synchronous by design: this is read before the first frame, which is
  /// why it lives in SharedPreferences and not in Drift.
  DevicePreferences read();

  Future<void> write(DevicePreferences prefs);
}

abstract interface class AccountProfileRepository {
  Stream<AccountProfile> watch();

  /// Patch semantics, never replace.
  ///
  /// A full-object update means a client running an older build
  /// overwrites fields it does not know about with its own defaults. That
  /// is the classic way settings silently reset after an app update.
  Future<Result<void, QFailure>> update(AccountProfilePatch patch);
}

/// Read-only, by construction. There is no write method and there will
/// not be one: a client that can set its own premium flag will have it
/// set for it within a week of launch.
abstract interface class EntitlementRepository {
  Stream<Entitlement> watch();

  /// Forces a receipt re-check. Rate limited server-side.
  Future<Result<void, QFailure>> refresh();
}

class AccountProfilePatch {
  const AccountProfilePatch({
    this.locale,
    this.calculationMethod,
    this.asrMethod,
    this.prayerAdjustments,
    this.notificationModes,
    this.translationPackIds,
    this.reciterId,
    this.displayName,
    this.analyticsOptIn,
  });

  final String? locale;
  final String? calculationMethod;
  final String? asrMethod;
  final Map<String, int>? prayerAdjustments;
  final Map<String, String>? notificationModes;
  final List<String>? translationPackIds;
  final String? reciterId;
  final String? displayName;
  final bool? analyticsOptIn;

  Map<String, dynamic> toJson() => {
        if (locale != null) 'locale': locale,
        if (calculationMethod != null)
          'calculation_method': calculationMethod,
        if (asrMethod != null) 'asr_method': asrMethod,
        if (prayerAdjustments != null)
          'prayer_adjustments': prayerAdjustments,
        if (notificationModes != null)
          'notification_modes': notificationModes,
        if (translationPackIds != null)
          'translation_pack_ids': translationPackIds,
        if (reciterId != null) 'reciter_id': reciterId,
        if (displayName != null) 'display_name': displayName,
        if (analyticsOptIn != null) 'analytics_opt_in': analyticsOptIn,
      };
}

class Entitlement {
  const Entitlement({
    required this.active,
    this.tier,
    this.expiresAt,
    this.inGracePeriod = false,
    this.verifiedAt,
  });

  final bool active;
  final String? tier;
  final DateTime? expiresAt;
  final bool inGracePeriod;

  /// When the server last confirmed this against a store receipt.
  final DateTime? verifiedAt;

  /// Cached entitlement is trusted offline for seven days.
  ///
  /// Someone on a plane with a valid subscription must keep the tafsir
  /// they downloaded. Seven days bounds the fraud window without
  /// punishing the honest majority, who are almost everyone.
  static const offlineGrace = Duration(days: 7);

  bool isUsableAt(DateTime now) {
    if (!active) return false;
    final checked = verifiedAt;
    if (checked == null) return false;
    return now.difference(checked) < offlineGrace;
  }
}
