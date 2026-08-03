"""One-time tokens for password reset and email verification.

IMPORTANT: import this module from apps/accounts/models.py so Django
discovers the model and generates a migration for it:

    from apps.accounts.tokens import OneTimeToken  # noqa: F401
"""

import hashlib
import secrets
from datetime import timedelta

from django.db import models
from django.utils import timezone

from apps.core.models import TimestampedModel, UUIDModel


class OneTimeToken(UUIDModel, TimestampedModel):
    """Password reset and email verification credentials.

    The token itself is never stored, only its SHA-256. A database dump
    therefore cannot be replayed against live accounts. This is the same
    reasoning that makes us hash passwords, applied to the credential that
    can *reset* a password.
    """

    class Purpose(models.TextChoices):
        PASSWORD_RESET = "password_reset", "Password reset"
        EMAIL_VERIFY = "email_verify", "Email verification"

    user = models.ForeignKey(
        "accounts.User",
        on_delete=models.CASCADE,
        related_name="one_time_tokens",
    )
    purpose = models.CharField(max_length=32, choices=Purpose.choices)
    token_hash = models.CharField(max_length=64, db_index=True)
    expires_at = models.DateTimeField()
    consumed_at = models.DateTimeField(null=True, blank=True)
    requested_ip = models.GenericIPAddressField(null=True, blank=True)

    TTL = {
        # Short, because a reset link is a live credential sitting in an
        # inbox that may be open on a shared or borrowed device.
        Purpose.PASSWORD_RESET: timedelta(minutes=30),
        Purpose.EMAIL_VERIFY: timedelta(days=1),
    }

    class Meta:
        db_table = "accounts_one_time_token"
        indexes = [
            models.Index(
                fields=["purpose", "token_hash"], name="idx_ott_lookup"
            ),
            models.Index(fields=["expires_at"], name="idx_ott_expiry"),
        ]

    def __str__(self) -> str:
        return f"{self.purpose} for {self.user_id}"

    @staticmethod
    def digest(raw: str) -> str:
        return hashlib.sha256(raw.encode()).hexdigest()

    @classmethod
    def issue(cls, user, purpose: str, ip: str | None = None) -> str:
        raw = secrets.token_urlsafe(48)

        # Invalidate outstanding tokens of the same purpose. Two live reset
        # links means an attacker who saw an older email still holds a
        # usable window.
        cls.objects.filter(
            user=user, purpose=purpose, consumed_at__isnull=True
        ).update(consumed_at=timezone.now())

        cls.objects.create(
            user=user,
            purpose=purpose,
            token_hash=cls.digest(raw),
            expires_at=timezone.now() + cls.TTL[purpose],
            requested_ip=ip,
        )
        return raw

    @classmethod
    def consume(cls, raw: str, purpose: str):
        """Returns the token if valid, else None. Caller must be atomic."""
        token = (
            cls.objects.select_for_update()
            .filter(
                purpose=purpose,
                token_hash=cls.digest(raw),
                consumed_at__isnull=True,
                expires_at__gt=timezone.now(),
            )
            .select_related("user")
            .first()
        )
        if token is not None:
            token.consumed_at = timezone.now()
            token.save(update_fields=["consumed_at"])
        return token

    @property
    def is_expired(self) -> bool:
        return timezone.now() >= self.expires_at
