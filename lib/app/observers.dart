import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_one/core/logging/logger.dart';

/// Logs every provider failure with the provider name attached.
///
/// Without this, provider errors are anonymous in production crash reports.
class QProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    QLog.instance.error(
      'provider failed: ${provider.name ?? provider.runtimeType}',
      error,
      stackTrace,
    );
  }
}
