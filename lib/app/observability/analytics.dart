/// Analytics, opt-in and event-typed.
///
/// Two rules the interface enforces rather than documents:
///
/// 1. Events are a sealed set, not free-form strings. A `log(String, Map)`
///    API becomes 400 undocumented event names within a year, and nobody
///    can answer what any of them mean.
/// 2. Nothing is sent until the user opts in. Default-on analytics for an
///    app that knows what scripture you read and when you pray is not a
///    growth decision, it is a betrayal.
sealed class AnalyticsEvent {
  const AnalyticsEvent();

  String get name;
  Map<String, Object?> get parameters => const {};
}

class AppOpened extends AnalyticsEvent {
  const AppOpened({required this.coldStartMs});
  final int coldStartMs;

  @override
  String get name => 'app_opened';

  @override
  Map<String, Object?> get parameters => {'cold_start_ms': coldStartMs};
}

class SurahOpened extends AnalyticsEvent {
  const SurahOpened(this.surah);
  final int surah;

  @override
  String get name => 'surah_opened';

  // The surah number only. Never the ayah, never the duration. Which
  // verses a person lingers on is not ours to collect.
  @override
  Map<String, Object?> get parameters => {'surah': surah};
}

class ContentPackInstalled extends AnalyticsEvent {
  const ContentPackInstalled(this.packId);
  final String packId;

  @override
  String get name => 'content_pack_installed';

  @override
  Map<String, Object?> get parameters => {'pack_id': packId};
}

abstract interface class Analytics {
  Future<void> setEnabled({required bool enabled});
  Future<void> log(AnalyticsEvent event);
}

class NoopAnalytics implements Analytics {
  const NoopAnalytics();

  @override
  Future<void> setEnabled({required bool enabled}) async {}

  @override
  Future<void> log(AnalyticsEvent event) async {}
}
