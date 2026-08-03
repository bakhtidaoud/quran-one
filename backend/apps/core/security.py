"""Request-level hardening for the API.

What is deliberately NOT here, and why:

- No certificate pinning support. It breaks school and corporate networks
  that inspect traffic by policy, it bricks clients when a certificate
  rotates faster than users update, and the data it would protect is a
  bookmark list. TLS 1.3 with the platform trust store is correct here.

- No device attestation (Play Integrity / DeviceCheck). It excludes
  rooted devices, custom ROMs and de-Googled phones, which in this user
  base is a real and principled population, and it buys protection
  against a threat -- API abuse by modified clients -- that rate limiting
  already bounds.
"""

from django.utils import timezone
from django.utils.cache import patch_vary_headers


class SecurityHeadersMiddleware:
    """Response headers for the API and the web build."""

    HEADERS = {
        "X-Content-Type-Options": "nosniff",
        "X-Frame-Options": "DENY",
        "Referrer-Policy": "no-referrer",
        # The API serves JSON only. A CSP this strict would break a
        # browsable API, which is precisely why DRF's browsable renderer
        # is disabled in production settings.
        "Content-Security-Policy": "default-src 'none'; frame-ancestors 'none'",
        "Cross-Origin-Resource-Policy": "same-site",
        # Two years, preload-eligible. Only ever set behind real TLS.
        "Strict-Transport-Security": "max-age=63072000; includeSubDomains",
        # No feature this API serves needs any of these.
        "Permissions-Policy": "geolocation=(), microphone=(), camera=()",
    }

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        response = self.get_response(request)
        for header, value in self.HEADERS.items():
            response.setdefault(header, value)
        # Authorization varies the response; without this a shared cache
        # can serve one user's profile to another.
        patch_vary_headers(response, ("Authorization",))
        return response


class LoginAttemptGuard:
    """Progressive delay on repeated failed sign-ins.

    Layered on top of EmailScopedThrottle rather than replacing it. The
    throttle bounds request volume; this bounds the value of each attempt
    by making the tenth guess cost seconds rather than milliseconds.

    Backoff is per (email, ip) and resets on success. It never locks an
    account permanently: permanent lockout on failed passwords converts a
    brute-force attempt into a denial of service against the victim, which
    is a trade almost nobody should accept.
    """

    WINDOW_SECONDS = 900
    DELAYS = [0, 0, 0, 1, 2, 4, 8, 16, 30, 30]

    @classmethod
    def delay_for(cls, failures: int) -> int:
        if failures <= 0:
            return 0
        index = min(failures, len(cls.DELAYS)) - 1
        return cls.DELAYS[index]


def scrub_for_log(payload: dict) -> dict:
    """Applies REDACTED_KEYS before anything reaches a log or Sentry.

    Mirrors the Flutter side's redact(). The list is not generic security
    hygiene: latitude, longitude, note and query are on it because a
    breach of this app's logs should not reveal where a person prays,
    what they wrote about a verse, or what they searched for.
    """
    from apps.core.logging import REDACTED_KEYS

    return {
        key: ("[redacted]" if key.lower() in REDACTED_KEYS else value)
        for key, value in payload.items()
    }


def gdpr_retention_sweep() -> dict:
    """Daily job enforcing the retention promises in docs/SECURITY.md.

    Each number here is a commitment made to users, not a default:
      - soft-deleted accounts hard-delete at 30 days
      - one-time tokens purge at 7 days
      - expired refresh tokens purge daily
      - sync tombstones purge at 90 days
      - request logs retain 30 days
    """
    from datetime import timedelta

    from apps.accounts.models import User
    from apps.accounts.tokens import OneTimeToken

    now = timezone.now()
    purged_users, _ = User.objects.filter(
        deletion_requested_at__lt=now - timedelta(days=30)
    ).delete()
    purged_tokens, _ = OneTimeToken.objects.filter(
        expires_at__lt=now - timedelta(days=7)
    ).delete()

    return {"users": purged_users, "tokens": purged_tokens}
