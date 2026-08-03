import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:quran_one/core/security/session_policy.dart';

/// Observes app lifecycle and drives proactive token refresh.
///
/// Two behaviours, both about avoiding a visible failure:
///
/// 1. On resume, if the access token is within the skew window, refresh
///    before the user's first tap produces a request. A 401 that the
///    interceptor silently recovers from still costs a round trip, and on
///    a 2G connection that round trip is the difference between instant
///    and sluggish.
///
/// 2. On resume after a long background period, check whether the refresh
///    token itself has expired. If it has, transition to Expired rather
///    than firing a doomed request.
class SessionWatcher with WidgetsBindingObserver {
  SessionWatcher({
    required SessionPolicy policy,
    required Future<void> Function() onRefreshNeeded,
    required Future<void> Function() onSessionDead,
    required DateTime? Function() accessExpiresAt,
    required DateTime? Function() refreshExpiresAt,
  })  : _policy = policy,
        _onRefreshNeeded = onRefreshNeeded,
        _onSessionDead = onSessionDead,
        _accessExpiresAt = accessExpiresAt,
        _refreshExpiresAt = refreshExpiresAt;

  final SessionPolicy _policy;
  final Future<void> Function() _onRefreshNeeded;
  final Future<void> Function() _onSessionDead;
  final DateTime? Function() _accessExpiresAt;
  final DateTime? Function() _refreshExpiresAt;

  DateTime? _backgroundedAt;

  void start() => WidgetsBinding.instance.addObserver(this);
  void dispose() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _backgroundedAt = DateTime.now();
      case AppLifecycleState.resumed:
        unawaited(_onResume());
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _onResume() async {
    final now = DateTime.now();

    final refreshExpiry = _refreshExpiresAt();
    if (refreshExpiry != null && now.isAfter(refreshExpiry)) {
      await _onSessionDead();
      return;
    }

    // Optional idle logout, off unless a policy sets it.
    final idle = _policy.idleLogout;
    final since = _backgroundedAt;
    if (idle != null && since != null && now.difference(since) > idle) {
      await _onSessionDead();
      return;
    }

    final accessExpiry = _accessExpiresAt();
    if (accessExpiry != null && _policy.shouldRefresh(accessExpiry, now)) {
      await _onRefreshNeeded();
    }
  }
}
