/// Every failure the application can surface.
///
/// Sealed so that presentation code must switch exhaustively: when a new
/// failure type is added, the compiler names every screen that has not
/// handled it.
///
/// Repositories return these inside a [Result]. They never throw.
sealed class QFailure {
  const QFailure(this.message, {this.traceId});

  /// Developer-facing detail. Never rendered directly to the user.
  final String message;

  /// Copyable identifier shown in error states. The difference between a
  /// solvable support ticket and an unsolvable one.
  final String? traceId;

  @override
  String toString() => '$runtimeType($message)';
}

final class NetworkFailure extends QFailure {
  const NetworkFailure(super.message, {super.traceId});
}

final class TimeoutFailure extends QFailure {
  const TimeoutFailure(super.message, {super.traceId});
}

final class ServerFailure extends QFailure {
  const ServerFailure(
    super.message, {
    required this.statusCode,
    this.type,
    super.traceId,
  });

  final int statusCode;

  /// RFC 9457 problem type URI.
  final String? type;
}

final class UnauthorizedFailure extends QFailure {
  const UnauthorizedFailure(super.message, {super.traceId});
}

final class RateLimitedFailure extends QFailure {
  const RateLimitedFailure(super.message, {this.retryAfter, super.traceId});

  final Duration? retryAfter;
}

final class CacheFailure extends QFailure {
  const CacheFailure(super.message, {super.traceId});
}

final class PermissionFailure extends QFailure {
  const PermissionFailure(super.message, {required this.permanentlyDenied});

  final bool permanentlyDenied;
}

final class ValidationFailure extends QFailure {
  const ValidationFailure(super.message, {this.field});

  final String? field;
}

final class SyncConflictFailure extends QFailure {
  const SyncConflictFailure(super.message, {super.traceId});
}

/// The requested content pack is not installed.
///
/// Deliberately distinct from [NetworkFailure]: the UI shows a download
/// action, not "something went wrong". Scripture is never fetched ad hoc
/// over the network.
final class ContentPackMissingFailure extends QFailure {
  const ContentPackMissingFailure([this.packId])
      : super('content pack missing');

  final String? packId;
}

final class UnknownFailure extends QFailure {
  const UnknownFailure(super.message, {super.traceId});
}
