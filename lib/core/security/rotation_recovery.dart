import 'package:flutter/foundation.dart';

/// Survives the one failure mode that refresh-token rotation guarantees.
///
/// The backend rotates and blacklists: every successful refresh issues a
/// new refresh token and kills the old one. That is correct, and it has
/// an unavoidable consequence. If the refresh request succeeds on the
/// server but the response is lost -- a tunnel, a dropped connection, a
/// process kill -- the client is holding a token the server has already
/// blacklisted. The next refresh returns 401 and the user is signed out
/// through no fault of their own.
///
/// This is not theoretical. On the mobile networks a large share of this
/// app's users are on, it happens constantly.
///
/// The mitigation has three parts:
///
/// 1. Single-flight refresh, already implemented in AuthInterceptor via
///    QueuedInterceptor. Six parallel 401s must produce one refresh, not
///    six, because five of them would be rejected as replays.
///
/// 2. Write-ahead. The new token pair is written to secure storage before
///    the response is acknowledged upstream, so a crash between receiving
///    and persisting cannot lose it.
///
/// 3. A short grace window on the server, configured via
///    SIMPLE_JWT["BLACKLIST_GRACE"], during which a just-rotated token is
///    still accepted once. Without it, part 2 only narrows the window
///    rather than closing it.
@immutable
class RotationRecovery {
  const RotationRecovery({
    this.maxConsecutiveFailures = 2,
    this.retryDelay = const Duration(seconds: 2),
  });

  /// After this many consecutive refresh failures, stop trying and move
  /// to Expired. Retrying a blacklisted token forever is how an app
  /// drains a battery overnight.
  final int maxConsecutiveFailures;

  final Duration retryDelay;
}

/// A dead refresh token is NOT a sign-out.
///
/// The state becomes Expired, not Guest: local data still belongs to a
/// known account, the app remains entirely usable, and the only visible
/// change is that the sync indicator stops. No dialog, no redirect to a
/// login screen, no interruption. If the app cannot recover silently, the
/// worst it may do is show a dismissible row in Settings.
enum SessionEndReason {
  refreshExpired,
  refreshRejected,
  passwordChanged,
  revokedRemotely,
  userSignedOut,
}
