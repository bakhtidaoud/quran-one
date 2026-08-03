"""Prayer support data.

Note what is absent: prayer times. They are computed on the device from an
astronomical model, because a prayer time that requires a network call is a
prayer time that fails on a plane, in a basement, and in the countries with
the worst connectivity and the most users.

The server holds only what the device genuinely cannot derive: calculation
method definitions, and per-region convention overrides.
"""

from django.db import models

from apps.core.models import TimestampedModel


class CalculationMethod(TimestampedModel):
    id = models.SlugField(primary_key=True, max_length=40)
    name = models.CharField(max_length=120)
    fajr_angle = models.DecimalField(max_digits=4, decimal_places=2)
    isha_angle = models.DecimalField(
        max_digits=4, decimal_places=2, null=True, blank=True
    )
    # Umm al-Qura and a few others use a fixed interval after Maghrib
    # instead of a solar depression angle.
    isha_interval_minutes = models.PositiveSmallIntegerField(
        null=True, blank=True
    )
    maghrib_angle = models.DecimalField(
        max_digits=4, decimal_places=2, null=True, blank=True
    )
    midnight_mode = models.CharField(max_length=20, default="standard")
    authority = models.CharField(max_length=160, blank=True)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = "prayer_calculation_method"
        ordering = ["name"]

    def __str__(self) -> str:
        return self.name


class RegionDefault(TimestampedModel):
    """What a user in this country expects before they touch settings.

    Getting this wrong is the single most common complaint about every
    competing app: a Moroccan user should not have to discover that the
    default is a Pakistani convention.
    """

    country_code = models.CharField(max_length=2, primary_key=True)
    method = models.ForeignKey(CalculationMethod, on_delete=models.PROTECT)
    asr_method = models.CharField(max_length=10, default="standard")
    high_latitude_rule = models.CharField(max_length=30, default="none")

    class Meta:
        db_table = "prayer_region_default"

    def __str__(self) -> str:
        return self.country_code


class Mosque(TimestampedModel):
    """Community-contributed, moderated before it is visible.

    Unverified mosque data sends people to a car park at Fajr.
    """

    name = models.CharField(max_length=200)
    country_code = models.CharField(max_length=2, db_index=True)
    city = models.CharField(max_length=120, blank=True)
    latitude = models.DecimalField(max_digits=8, decimal_places=5)
    longitude = models.DecimalField(max_digits=8, decimal_places=5)
    jumuah_time = models.TimeField(null=True, blank=True)
    is_verified = models.BooleanField(default=False, db_index=True)

    class Meta:
        db_table = "prayer_mosque"
        indexes = [models.Index(fields=["country_code", "city"])]

    def __str__(self) -> str:
        return self.name
