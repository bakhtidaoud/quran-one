"""Scripture. Read-only at runtime.

No view in this app writes. These tables are populated by a management
command from a checksummed source file and are never mutated by a request
handler. That is enforced by `ImmutableModel.save`, not by convention.
"""

from django.contrib.postgres.indexes import GinIndex
from django.contrib.postgres.search import SearchVectorField
from django.core.exceptions import PermissionDenied
from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models

from apps.core.models import TimestampedModel, UUIDModel


class ImmutableModel(models.Model):
    class Meta:
        abstract = True

    def save(self, *args, **kwargs):
        allow = kwargs.pop("allow_scripture_write", False)
        if not allow and self.pk is not None:
            raise PermissionDenied(
                "Scripture rows are immutable. Ship a new content pack "
                "version instead of editing a row."
            )
        return super().save(*args, **kwargs)

    def delete(self, *args, **kwargs):
        raise PermissionDenied("Scripture rows cannot be deleted.")


class Surah(ImmutableModel):
    MECCAN = "meccan"
    MEDINAN = "medinan"

    number = models.PositiveSmallIntegerField(
        primary_key=True,
        validators=[MinValueValidator(1), MaxValueValidator(114)],
    )
    arabic_name = models.CharField(max_length=80)
    latin_name = models.CharField(max_length=80)
    english_name = models.CharField(max_length=120)
    ayah_count = models.PositiveSmallIntegerField()
    revelation = models.CharField(
        max_length=8, choices=[(MECCAN, "Meccan"), (MEDINAN, "Medinan")]
    )
    revelation_order = models.PositiveSmallIntegerField()
    start_page = models.PositiveSmallIntegerField()
    has_bismillah = models.BooleanField(default=True)

    class Meta:
        db_table = "quran_surah"
        ordering = ["number"]

    def __str__(self) -> str:
        return f"{self.number}. {self.latin_name}"


class Ayah(ImmutableModel):
    """6,236 rows. Fixed forever.

    `uthmani` and `simple` are stored separately rather than derived,
    because stripping diacritics correctly is script-specific and getting it
    wrong at runtime would corrupt what a user reads.
    """

    id = models.PositiveSmallIntegerField(primary_key=True)  # 1..6236
    surah = models.ForeignKey(
        Surah, on_delete=models.PROTECT, related_name="ayat", db_column="surah"
    )
    number = models.PositiveSmallIntegerField()
    uthmani = models.TextField()
    simple = models.TextField()
    juz = models.PositiveSmallIntegerField(db_index=True)
    hizb = models.PositiveSmallIntegerField()
    rub = models.PositiveSmallIntegerField()
    page = models.PositiveSmallIntegerField(db_index=True)
    ruku = models.PositiveSmallIntegerField()
    manzil = models.PositiveSmallIntegerField()
    sajdah = models.BooleanField(default=False)
    sajdah_obligatory = models.BooleanField(default=False)
    search_vector = SearchVectorField(null=True, editable=False)

    class Meta:
        db_table = "quran_ayah"
        ordering = ["id"]
        constraints = [
            models.UniqueConstraint(
                fields=["surah", "number"], name="uniq_surah_ayah"
            )
        ]
        indexes = [
            models.Index(fields=["surah", "number"], name="idx_ayah_ref"),
            models.Index(fields=["page", "id"], name="idx_ayah_page"),
            GinIndex(fields=["search_vector"], name="idx_ayah_search"),
        ]

    def __str__(self) -> str:
        return f"{self.surah_id}:{self.number}"


class Translation(TimestampedModel):
    """A licensed work, not the text itself.

    `license_expires_at` exists because losing a licence is a scheduled
    event, not a surprise. A nightly task flags works approaching expiry so
    they can be withdrawn from the catalogue before the lawyers call.
    """

    id = models.SlugField(primary_key=True, max_length=40)
    language = models.CharField(max_length=10, db_index=True)
    name = models.CharField(max_length=160)
    translator = models.CharField(max_length=160)
    source_url = models.URLField(blank=True)
    license_name = models.CharField(max_length=120)
    license_expires_at = models.DateField(null=True, blank=True)
    direction = models.CharField(max_length=3, default="ltr")
    is_active = models.BooleanField(default=True, db_index=True)

    class Meta:
        db_table = "quran_translation"
        ordering = ["language", "name"]

    def __str__(self) -> str:
        return f"{self.name} ({self.language})"


class TranslationText(models.Model):
    translation = models.ForeignKey(
        Translation, on_delete=models.CASCADE, related_name="texts"
    )
    ayah = models.ForeignKey(
        Ayah, on_delete=models.PROTECT, related_name="translations"
    )
    text = models.TextField()
    footnotes = models.JSONField(default=list, blank=True)

    class Meta:
        db_table = "quran_translation_text"
        constraints = [
            models.UniqueConstraint(
                fields=["translation", "ayah"], name="uniq_translation_ayah"
            )
        ]
        indexes = [models.Index(fields=["translation", "ayah"])]


class Reciter(TimestampedModel):
    id = models.SlugField(primary_key=True, max_length=40)
    name = models.CharField(max_length=160)
    arabic_name = models.CharField(max_length=160, blank=True)
    style = models.CharField(max_length=40, blank=True)  # murattal, mujawwad
    riwayah = models.CharField(max_length=40, default="hafs")
    has_ayah_timings = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = "quran_reciter"
        ordering = ["name"]

    def __str__(self) -> str:
        return self.name


class Bookmark(UUIDModel, TimestampedModel):
    """User content, and the only writable table in this app.

    `client_updated_at` is the sync clock. The server's own updated_at is
    when the row arrived, which is a different question and a useless one
    for conflict resolution.
    """

    user = models.ForeignKey(
        "accounts.User", on_delete=models.CASCADE, related_name="bookmarks"
    )
    ayah = models.ForeignKey(Ayah, on_delete=models.PROTECT)
    note = models.TextField(blank=True, max_length=4000)
    highlight_color = models.CharField(max_length=16, blank=True)
    folder = models.CharField(max_length=80, blank=True)
    client_updated_at = models.DateTimeField(db_index=True)
    deleted = models.BooleanField(default=False)

    class Meta:
        db_table = "quran_bookmark"
        ordering = ["-client_updated_at"]
        indexes = [
            models.Index(
                fields=["user", "client_updated_at"], name="idx_bookmark_sync"
            ),
        ]

    def __str__(self) -> str:
        return f"{self.user_id} -> {self.ayah_id}"
