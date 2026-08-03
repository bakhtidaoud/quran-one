"""Sync state.

The client is authoritative for worship data. The server stores and
redistributes it; it does not arbitrate what a user memorised. That single
decision removes most of the conflict surface, because the only genuine
conflict is two devices editing the same row.
"""

from django.db import models

from apps.core.models import TimestampedModel, UUIDModel


class Device(TimestampedModel):
    id = models.CharField(primary_key=True, max_length=64)
    user = models.ForeignKey(
        "accounts.User", on_delete=models.CASCADE, related_name="devices"
    )
    platform = models.CharField(max_length=12)  # android, ios, web
    app_version = models.CharField(max_length=20)
    push_token = models.CharField(max_length=400, blank=True)
    last_sync_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = "sync_device"

    def __str__(self) -> str:
        return f"{self.platform}:{self.id[:8]}"


class HifzCard(UUIDModel, TimestampedModel):
    """Spaced-repetition state for one ayah.

    This is the most irreplaceable data in the product. A user can lose
    bookmarks and shrug; losing three years of memorisation scheduling is
    unforgivable. Hence: never hard-deleted, never overwritten blindly, and
    every write keeps a revision counter.
    """

    user = models.ForeignKey(
        "accounts.User", on_delete=models.CASCADE, related_name="hifz_cards"
    )
    ayah = models.ForeignKey("quran.Ayah", on_delete=models.PROTECT)
    ease = models.FloatField(default=2.5)
    interval_days = models.PositiveIntegerField(default=0)
    repetitions = models.PositiveIntegerField(default=0)
    lapses = models.PositiveIntegerField(default=0)
    due_at = models.DateTimeField(db_index=True)
    last_reviewed_at = models.DateTimeField(null=True, blank=True)
    client_updated_at = models.DateTimeField(db_index=True)
    revision = models.PositiveIntegerField(default=1)

    class Meta:
        db_table = "sync_hifz_card"
        constraints = [
            models.UniqueConstraint(
                fields=["user", "ayah"], name="uniq_user_hifz_ayah"
            )
        ]
        indexes = [
            models.Index(
                fields=["user", "client_updated_at"], name="idx_hifz_sync"
            )
        ]


class ReadingPosition(TimestampedModel):
    user = models.ForeignKey(
        "accounts.User", on_delete=models.CASCADE, related_name="positions"
    )
    mode = models.CharField(max_length=20)  # mushaf, translation, audio
    surah = models.PositiveSmallIntegerField()
    ayah = models.PositiveSmallIntegerField()
    page = models.PositiveSmallIntegerField(null=True, blank=True)
    client_updated_at = models.DateTimeField()

    class Meta:
        db_table = "sync_reading_position"
        constraints = [
            models.UniqueConstraint(
                fields=["user", "mode"], name="uniq_user_mode_position"
            )
        ]


class SyncConflict(UUIDModel, TimestampedModel):
    """Kept, not discarded.

    When last-write-wins throws away a losing version, the losing version is
    written here first. If the resolution turns out to be wrong, the data
    still exists. This table is the difference between a sync bug and
    permanent loss.
    """

    user = models.ForeignKey("accounts.User", on_delete=models.CASCADE)
    entity_type = models.CharField(max_length=40)
    entity_id = models.CharField(max_length=64)
    losing_payload = models.JSONField()
    winning_client_updated_at = models.DateTimeField()
    losing_client_updated_at = models.DateTimeField()

    class Meta:
        db_table = "sync_conflict"
        indexes = [models.Index(fields=["user", "entity_type"])]
