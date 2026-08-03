"""Subscriptions.

The server is authoritative here, and only here. Everything else in this
product trusts the client; money does not. Entitlement is derived from a
store receipt validated server-side, never from a client claim.
"""

from django.db import models

from apps.core.models import TimestampedModel, UUIDModel


class Subscription(UUIDModel, TimestampedModel):
    APPLE = "apple"
    GOOGLE = "google"
    STRIPE = "stripe"

    user = models.ForeignKey(
        "accounts.User", on_delete=models.CASCADE, related_name="subscriptions"
    )
    platform = models.CharField(
        max_length=10,
        choices=[(APPLE, "Apple"), (GOOGLE, "Google"), (STRIPE, "Stripe")],
    )
    product_id = models.CharField(max_length=80)
    original_transaction_id = models.CharField(max_length=120, db_index=True)
    # Regional pricing tier. A single global price excludes most of the
    # intended audience, which defeats the purpose of the product.
    price_tier = models.PositiveSmallIntegerField(default=1)
    started_at = models.DateTimeField()
    expires_at = models.DateTimeField(db_index=True)
    cancelled_at = models.DateTimeField(null=True, blank=True)
    in_grace_period = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True, db_index=True)

    class Meta:
        db_table = "billing_subscription"
        constraints = [
            models.UniqueConstraint(
                fields=["platform", "original_transaction_id"],
                name="uniq_platform_transaction",
            )
        ]

    def __str__(self) -> str:
        return f"{self.user_id} {self.product_id}"


class WebhookEvent(TimestampedModel):
    """Every store callback, stored before it is processed.

    Stores retry aggressively and out of order. Recording the raw event and
    de-duplicating on the store's own event id is what keeps a double
    delivery from granting or revoking twice.
    """

    platform = models.CharField(max_length=10)
    event_id = models.CharField(max_length=160)
    payload = models.JSONField()
    processed_at = models.DateTimeField(null=True, blank=True)
    error = models.TextField(blank=True)

    class Meta:
        db_table = "billing_webhook_event"
        constraints = [
            models.UniqueConstraint(
                fields=["platform", "event_id"], name="uniq_webhook_event"
            )
        ]
