"""Server-side session hardening.

Recommended SIMPLE_JWT configuration, with the reasoning:

    SIMPLE_JWT = {
        "ACCESS_TOKEN_LIFETIME": timedelta(minutes=30),
        "REFRESH_TOKEN_LIFETIME": timedelta(days=90),
        "ROTATE_REFRESH_TOKENS": True,
        "BLACKLIST_AFTER_ROTATION": True,
        "UPDATE_LAST_LOGIN": False,
        "ALGORITHM": "RS256",
        "SIGNING_KEY": <private key from the secret manager>,
        "VERIFYING_KEY": <public key>,
        "USER_ID_CLAIM": "sub",
        "AUTH_HEADER_TYPES": ("Bearer",),
    }

RS256 rather than HS256, deliberately. With a shared secret, every
service able to *verify* a token is also able to *mint* one, so a
read-only analytics worker with a config leak becomes a token factory.
Asymmetric signing keeps minting in one place.

UPDATE_LAST_LOGIN is False because it issues a write to the user row on
every single token refresh, which at scale is a hot-row contention
problem for a field nobody reads.
"""

from django.utils import timezone
from rest_framework_simplejwt.token_blacklist.models import (
    BlacklistedToken,
    OutstandingToken,
)


def revoke_all_sessions(user, *, keep_jti: str | None = None) -> int:
    """Blacklists every outstanding refresh token for a user.

    keep_jti spares the current session. Used on password change, where
    signing the user out of the session they are actively using to improve
    their security is a punishment for good hygiene. NOT used on password
    reset, where the premise is that the account may already be
    compromised and every session is suspect.
    """
    revoked = 0
    tokens = OutstandingToken.objects.filter(
        user=user, expires_at__gt=timezone.now()
    )
    for token in tokens:
        if keep_jti and token.jti == keep_jti:
            continue
        _, created = BlacklistedToken.objects.get_or_create(token=token)
        revoked += int(created)
    return revoked


def prune_expired_tokens() -> int:
    """Deletes outstanding tokens that have already expired.

    Without this the outstanding token table grows without bound: one row
    per refresh, per device, forever. At a thirty-minute access lifetime
    that is roughly forty-eight rows per active device per day. Run daily
    on the default queue.
    """
    deleted, _ = OutstandingToken.objects.filter(
        expires_at__lt=timezone.now()
    ).delete()
    return deleted


# Security recommendations that are NOT code, and are load-bearing:
#
# 1. Certificate pinning is deliberately omitted. It breaks corporate and
#    school networks that MITM by policy, it bricks the app when a
#    certificate rotates faster than users update, and the data it would
#    protect is a bookmark list. TLS 1.3 with a normal trust store is the
#    right call here.
#
# 2. Refresh tokens live in the platform keychain via
#    flutter_secure_storage, never in SharedPreferences. On Android,
#    preferences are plain XML readable by anything with root; the
#    keychain is hardware-backed on any device from the last several
#    years.
#
# 3. The `onboarded` flag and theme mode stay in SharedPreferences and
#    must never move to the keychain. Keychain reads are slow and can
#    block before the first frame, and these values are read on every
#    cold start.
#
# 4. No token is ever written to a log, a crash report, or a Celery task
#    argument that lands in Flower. REDACTED_KEYS in apps/core/logging.py
#    covers the first two; the reset task's raw token argument is the
#    known exception and its queue must not be shared externally.
#
# 5. Session listings show a city, never an IP address. City answers "was
#    this me?"; a stored IP against religious activity is a record nobody
#    should be holding.
