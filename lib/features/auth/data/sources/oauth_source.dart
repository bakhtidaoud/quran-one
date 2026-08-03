import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:quran_one/core/error/q_failure.dart';
import 'package:quran_one/core/error/result.dart';
import 'package:quran_one/features/auth/domain/repositories/auth_repository.dart';

/// The only file in the application that imports a provider SDK.
///
/// Everything above this line sees signInWithProvider(AuthProvider) and
/// never learns that Google and Apple differ.
abstract interface class OAuthSource {
  Future<Result<ProviderCredential, QFailure>> authorize(AuthProvider provider);
  Future<void> signOut();
}

@immutable
class ProviderCredential {
  const ProviderCredential({
    required this.provider,
    required this.identityToken,
    required this.rawNonce,
    this.email,
    this.displayName,
  });

  final AuthProvider provider;

  /// The OIDC ID token. Never the access token.
  ///
  /// An access token is a bearer credential for the provider's own API and
  /// can be minted by any application; a server that accepts one is
  /// trivially fooled by a token obtained elsewhere. The ID token is a
  /// signed JWT whose signature the server verifies against the
  /// provider's JWKS, with aud pinned to our own client id.
  final String identityToken;

  /// Sent alongside the token so the server can hash it and compare
  /// against the nonce claim inside. This is what makes a captured token
  /// useless on replay.
  final String rawNonce;

  /// Apple returns these on the FIRST authorisation only, ever, per Apple
  /// ID per bundle identifier. There is no API to retrieve them again. If
  /// the server discards them, the account has no name and possibly no
  /// usable email for its entire life.
  final String? email;
  final String? displayName;
}

/// Cancellation is not a failure.
///
/// Showing a red banner because someone changed their mind at the system
/// sheet is the most common defect in social sign-in implementations.
class CancelledFailure extends QFailure {
  const CancelledFailure() : super(message: 'Cancelled', traceId: null);
}

String generateNonce([int length = 32]) {
  // Random.secure, never Random(). The default generator is seeded
  // predictably, and a guessable nonce defeats the whole replay defence.
  final random = Random.secure();
  const chars =
      '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-._';
  return List.generate(length, (_) => chars[random.nextInt(chars.length)])
      .join();
}

String hashedNonce(String rawNonce) =>
    sha256.convert(utf8.encode(rawNonce)).toString();
