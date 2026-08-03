/// Build flavours. Selected at compile time by the entry point file.
enum Flavour {
  dev,
  staging,
  prod;

  bool get isProd => this == Flavour.prod;
  bool get isDev => this == Flavour.dev;
}

/// Compile-time configuration, supplied via --dart-define-from-file.
///
/// Never put secrets here. dart-define values are recoverable from the
/// shipped binary with `strings`. Anything sensitive is fetched at runtime
/// after authentication.
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.cdnBaseUrl,
    required this.analyticsEnabled,
    required this.logLevel,
  });

  const AppConfig.fromEnvironment()
      : apiBaseUrl = const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://api.quranone.app/v1',
        ),
        cdnBaseUrl = const String.fromEnvironment(
          'CDN_BASE_URL',
          defaultValue: 'https://cdn.quranone.app',
        ),
        analyticsEnabled = const bool.fromEnvironment(
          'ANALYTICS_ENABLED',
        ),
        logLevel = const String.fromEnvironment(
          'LOG_LEVEL',
          defaultValue: 'warning',
        );

  /// Test configuration. Points nowhere on purpose.
  const AppConfig.test()
      : apiBaseUrl = 'http://localhost:0/v1',
        cdnBaseUrl = 'http://localhost:0',
        analyticsEnabled = false,
        logLevel = 'debug';

  final String apiBaseUrl;
  final String cdnBaseUrl;
  final bool analyticsEnabled;
  final String logLevel;
}
