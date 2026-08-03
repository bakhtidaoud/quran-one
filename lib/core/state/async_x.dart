import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_one/core/error/q_failure.dart';

extension AsyncValueX<T> on AsyncValue<T> {
  /// The distinction the whole reading experience depends on.
  ///
  /// `isLoading` is also true during a refresh while valid data is already
  /// on screen. Driving a spinner from it makes the mushaf flash blank
  /// every time a translation pack updates. This is true only when there is
  /// genuinely nothing to show yet.
  bool get isInitialLoad => isLoading && !hasValue;

  /// True while refreshing over existing data. Drive a hairline indicator
  /// with this, never a full-screen state.
  bool get isRefreshing => isLoading && hasValue;

  QFailure? get failure {
    final e = error;
    return e is QFailure ? e : null;
  }

  /// Renders content the moment it exists and keeps rendering it through
  /// every subsequent failure.
  ///
  /// Offline is the default assumption, so a network error sitting on top
  /// of cached ayat is a footnote, not a screen. The stock `when` throws
  /// that data away.
  R when3<R>({
    required R Function(T value) data,
    required R Function() loading,
    required R Function(QFailure failure) error,
  }) {
    if (hasValue) return data(requireValue);
    if (hasError) {
      return error(failure ?? UnknownFailure(this.error.toString()));
    }
    return loading();
  }
}

extension AsyncWidgetX<T> on AsyncValue<T> {
  Widget widget({
    required Widget Function(T value) data,
    required Widget Function() loading,
    required Widget Function(QFailure failure) error,
  }) =>
      when3(data: data, loading: loading, error: error);
}
