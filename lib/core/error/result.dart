import 'package:quran_one/core/error/q_failure.dart';

/// Explicit success-or-failure return type.
///
/// Repositories return `Result` rather than throwing. Exceptions as control
/// flow do not survive nine engineers and fifteen features.
sealed class Result<T, E extends QFailure> {
  const Result();

  bool get isOk => this is Ok<T, E>;

  bool get isErr => this is Err<T, E>;

  /// The value, or null when this is a failure.
  T? get valueOrNull => switch (this) {
        Ok<T, E>(:final value) => value,
        Err<T, E>() => null,
      };

  /// The failure, or null when this is a success.
  E? get errorOrNull => switch (this) {
        Ok<T, E>() => null,
        Err<T, E>(:final error) => error,
      };

  R fold<R>(R Function(T value) onOk, R Function(E error) onErr) =>
      switch (this) {
        Ok<T, E>(:final value) => onOk(value),
        Err<T, E>(:final error) => onErr(error),
      };

  Result<R, E> map<R>(R Function(T value) transform) => switch (this) {
        Ok<T, E>(:final value) => Ok(transform(value)),
        Err<T, E>(:final error) => Err(error),
      };

  Future<Result<R, E>> flatMap<R>(
    Future<Result<R, E>> Function(T value) transform,
  ) async =>
      switch (this) {
        Ok<T, E>(:final value) => await transform(value),
        Err<T, E>(:final error) => Err(error),
      };
}

final class Ok<T, E extends QFailure> extends Result<T, E> {
  const Ok(this.value);

  final T value;
}

final class Err<T, E extends QFailure> extends Result<T, E> {
  const Err(this.error);

  final E error;
}
