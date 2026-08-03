"""Content packs: the mechanism that lets sacred text change without a
release, and the reason nothing sacred is bundled in the binary.

A pack is immutable once published. A correction is a new version, never an
edit, so that a device can always prove what it is holding.
"""

from django.core.exceptions import ValidationError
from django.db import models

from apps.core.models import TimestampedModel


class ContentPack(TimestampedModel):
    QURAN_TEXT = "quran_text"
    TRANSLATION = "translation"
    TAFSIR = "tafsir"
    AUDIO = "audio"
    FONT = "font"
    HADITH = "hadith"
    AZKAR = "azkar"

    KINDS = [
        (QURAN_TEXT, "Quran text"),
        (TRANSLATION, "Translation"),
        (TAFSIR, "Tafsir"),
        (AUDIO, "Audio"),
        (FONT, "Font"),
        (HADITH, "Hadith"),
        (AZKAR, "Azkar"),
    ]

    id = models.SlugField(primary_key=True, max_length=80)
    kind = models.CharField(max_length=20, choices=KINDS, db_index=True)
    name = models.CharField(max_length=160)
    language = models.CharField(max_length=10, blank=True, db_index=True)
    is_premium = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True, db_index=True)
    min_app_version = models.CharField(max_length=20, default="1.0.0")

    class Meta:
        db_table = "content_pack"
        ordering = ["kind", "name"]

    def __str__(self) -> str:
        return self.id


class ContentPackVersion(TimestampedModel):
    pack = models.ForeignKey(
        ContentPack, on_delete=models.PROTECT, related_name="versions"
    )
    version = models.PositiveIntegerField()
    object_key = models.CharField(max_length=400)
    size_bytes = models.BigIntegerField()
    # SHA-256 of the payload. The client refuses to install a pack whose
    # bytes do not hash to this value. Corrupted scripture must fail closed.
    checksum = models.CharField(max_length=64)
    signature = models.TextField(blank=True)
    published_at = models.DateTimeField(null=True, blank=True, db_index=True)
    revoked_at = models.DateTimeField(null=True, blank=True)
    changelog = models.TextField(blank=True)

    class Meta:
        db_table = "content_pack_version"
        ordering = ["-version"]
        constraints = [
            models.UniqueConstraint(
                fields=["pack", "version"], name="uniq_pack_version"
            )
        ]

    def __str__(self) -> str:
        return f"{self.pack_id} v{self.version}"

    def clean(self) -> None:
        if len(self.checksum) != 64:
            raise ValidationError({"checksum": "Expected a SHA-256 hex digest."})

    def save(self, *args, **kwargs):
        if self.pk is not None and self.published_at is not None:
            # Republishing under the same version number would let two
            # devices hold different bytes while both believing they are
            # current.
            allowed = {"revoked_at"}
            fields = set(kwargs.get("update_fields") or [])
            if not fields or not fields.issubset(allowed):
                raise ValidationError(
                    "A published pack version is immutable. Publish a new "
                    "version or revoke this one."
                )
        return super().save(*args, **kwargs)
