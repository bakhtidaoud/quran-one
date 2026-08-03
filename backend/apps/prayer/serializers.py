from rest_framework import serializers

from .models import CalculationMethod, Mosque, RegionDefault


class CalculationMethodSerializer(serializers.ModelSerializer):
    class Meta:
        model = CalculationMethod
        fields = (
            "id",
            "name",
            "fajr_angle",
            "isha_angle",
            "isha_interval_minutes",
            "maghrib_angle",
            "midnight_mode",
            "authority",
        )


class RegionDefaultSerializer(serializers.ModelSerializer):
    method = serializers.PrimaryKeyRelatedField(read_only=True)

    class Meta:
        model = RegionDefault
        fields = ("country_code", "method", "asr_method", "high_latitude_rule")


class MosqueSerializer(serializers.ModelSerializer):
    class Meta:
        model = Mosque
        fields = (
            "id",
            "name",
            "country_code",
            "city",
            "latitude",
            "longitude",
            "jumuah_time",
        )
