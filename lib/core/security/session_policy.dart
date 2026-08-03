import 'package:flutter/foundation.dart';

/// Session lifetimes, in one place, with the reasoning attached.
///
/// The usual mistake is copying a banking app's numbers into a Quran
/// reader. The threat models are not comparable: the worst outcome of a
/// stolen session here is that someone reads a bookmark list, whereas the
/// cost of an aggressive timeout is a person being asked to sign in
/// during Fajr on a phone with no signal.
@immutable
class SessionPolicy {
  const SessionPolicy({
    this.accessTokenTtl = const Duration(minutes: 30),
    this.refreshTokenTtl = const Duration(days: 90),
    this.refreshSkew = const Duration(minutes: 5),
    this.idleLogout,
  });

  /// Short, because it is the only credential sent on every request and
  /// it cannot be revoked before it expires. Thirty minutes bounds the
  /// damage of a leaked token without generating constant refresh churn.
  final Duration accessTokenTtl;

  /// Long, because this app must work after three months in airplane
  /// mode. A ninety-day refresh token is revocable at any moment via the
  /// blacklist, which is the property that actually matters.
  final Duration refreshTokenTtl;

  /// Refresh proactively this far before expiry, so a request never has
  /// to fail with a 401 first when the app is already online and idle.
  final Duration refreshSkew;

  /// Null by default. There is no idle logout.
  ///
  /// This is a deliberate refusal, not an oversight. Automatic sign-out
  /// after inactivity protects an account holding bookmarks and
  /// memorisation progress -- not money, not messages, not health
  /// records. The cost is real: the user who opens the app once a month
  /// in Ramadan finds themselves locked out at the exact moment they
  /// wanted it. If a deployment genuinely needs it, set this and the
  /// session watcher below enforces it.
  final Duration? idleLogout;

  bool shouldRefresh(DateTime expiresAt, DateTime now) =>
      now.isAfter(expiresAt.subtract(refreshSkew));
}

/// What the access token is allowed to contain.
///
/// A JWT is signed, not encrypted. Every claim is readable by anyone who
/// captures it, including the user, including a proxy. Claims are
/// therefore restricted to what is safe in plaintext: subject, issue and
/// expiry times, token id, and token type. No email, no display name, no
/// entitlement tier, no locale, and above all no reading history.
///
/// Entitlement in particular must never be a claim. A client that can
/// read its premium tier from a token is one base64 decode away from a
/// client that fabricates one, and a thirty-minute claim cannot be
/// revoked when a subscription is refunded.
const allowedAccessClaims = <String>{
  'sub',
  'iat',
  'exp',
  'jti',
  'token_type',
};
