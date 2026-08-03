import 'package:quran_one/core/error/q_failure.dart';
import 'package:quran_one/core/error/result.dart';
import 'package:quran_one/features/auth/domain/entities/session.dart';

enum AuthProvider { google, apple }

abstract interface class AuthRepository {
  Stream<AuthState> watch();

  /// Reads persisted credentials and returns the resulting state.
  /// Never throws: a corrupt keychain entry resolves to Guest.
  Future<AuthState> restore();

  Future<Result<Session, QFailure>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<Session, QFailure>> register({
    required String email,
    required String password,
    String? displayName,
  });

  /// Google and Apple collapse into one method.
  ///
  /// Both are the same shape: obtain an identity token from the platform,
  /// exchange it at /v1/auth/social/<provider> for our own JWT pair. Two
  /// methods would mean two code paths to keep correct for one behaviour.
  Future<Result<Session, QFailure>> signInWithProvider(AuthProvider provider);

  Future<Result<void, QFailure>> signOut({bool everywhere = false});

  Future<Result<void, QFailure>> requestPasswordReset(String email);
}
