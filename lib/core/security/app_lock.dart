import 'package:flutter/foundation.dart';

/// Optional biometric or PIN gate. Off by default.
///
/// A note on the reversal: earlier in this project I argued against an
/// app lock, on the grounds that it protects nothing against an attacker
/// with filesystem access and adds a barrier to opening the Quran. That
/// argument was answering the wrong threat.
///
/// The real threat here is not a forensic adversary. It is a shared or
/// borrowed phone, a family member scrolling through someone's private
/// notes, or a person in a context where their practice is not safe to
/// disclose. Against that threat a lock works, and the people who need it
/// need it badly.
///
/// So it ships, with three constraints:
///
/// 1. Off by default. Never prompted during onboarding.
/// 2. Scoped, not global. The default scope is private content -- notes
///    and settings -- and NOT the mushaf. Locking scripture behind a
///    fingerprint is the barrier I objected to, and it remains wrong.
/// 3. Biometrics gate access, they never protect data. The keychain does
///    that. A biometric check is a boolean returned by the OS, and a
///    patched binary returns true. Never gate a decryption on it in a
///    way that a `if (authenticated)` branch could bypass.
enum AppLockScope {
  /// Notes, settings, account. The default when a lock is enabled.
  privateContent,

  /// The whole app on cold start and resume. Opt-in within opt-in.
  entireApp,
}

enum AppLockMethod { none, biometric, pin, biometricWithPinFallback }

@immutable
class AppLockPolicy {
  const AppLockPolicy({
    this.method = AppLockMethod.none,
    this.scope = AppLockScope.privateContent,
    this.graceAfterBackground = const Duration(minutes: 2),
    this.maxPinAttempts = 10,
  });

  final AppLockMethod method;
  final AppLockScope scope;

  /// Re-prompting after a two-second app switch to check a message is
  /// how a lock gets disabled by the user within a day. Two minutes is
  /// long enough to be tolerable and short enough to matter.
  final Duration graceAfterBackground;

  /// After this many wrong PINs, the lock escalates to requiring the
  /// account password.
  ///
  /// It does NOT wipe local data. Remote-wipe-on-failed-PIN is a feature
  /// for enterprise MDM, and shipping it here means a child playing with
  /// a parent's phone destroys years of memorisation history.
  final int maxPinAttempts;

  bool get isEnabled => method != AppLockMethod.none;
}

/// PIN storage rules, which are the part that is usually wrong.
///
/// The PIN is never stored, in any form, anywhere. What is stored in the
/// keychain is a salted Argon2id (or PBKDF2-SHA256 with >= 200k
/// iterations if Argon2 is unavailable) hash of it, with a per-install
/// random salt.
///
/// A four-digit PIN has ten thousand possibilities, so the hash is
/// bruteforceable in milliseconds by anyone who extracts it. The
/// mitigations are the attempt counter above and the fact that the PIN
/// guards a UI gate rather than a decryption key. Do not pretend a PIN
/// provides cryptographic strength; it provides a speed bump against a
/// person holding the unlocked phone, which is exactly the threat.
abstract interface class AppLockStore {
  Future<bool> verifyPin(String pin);
  Future<void> setPin(String pin);
  Future<void> clearPin();
  Future<int> failedAttempts();
  Future<void> recordFailure();
  Future<void> resetFailures();
}
