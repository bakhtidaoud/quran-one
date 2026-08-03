from rest_framework import serializers

from .models import Ayah, Bookmark, Reciter, Surah, Translation


class SurahSerializer(serializers.ModelSerializer):
    class Meta:
        model = Surah
        fields = (
            "number",
            "arabic_name",
            "latin_name",
            "english_name",
            "ayah_count",
            "revelation",
            "revelation_order",
            "start_page",
            "has_bismillah",
        )


class AyahSerializer(serializers.ModelSerializer):
    reference = serializers.SerializerMethodField()

    class Meta:
        model = Ayah
        fields = (
            "id",
            "reference",
            "surah",
            "number",
            "uthmani",
            "simple",
            "juz",
            "hizb",
            "page",
            "sajdah",
            "sajdah_obligatory",
        )

    def get_reference(self, obj: Ayah) -> str:
        return f"{obj.surah_id}:{obj.number}"


class TranslationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Translation
        fields = (
            "id",
            "language",
            "name",
            "translator",
            "license_name",
            "direction",
        )


class ReciterSerializer(serializers.ModelSerializer):
    class Meta:
        model = Reciter
        fields = (
            "id",
            "name",
            "arabic_name",
            "style",
            "riwayah",
            "has_ayah_timings",
        )


class BookmarkSerializer(serializers.ModelSerializer):
    class Meta:
        model = Bookmark
        fields = (
            "id",
            "ayah",
            "note",
            "highlight_color",
            "folder",
            "client_updated_at",
            "deleted",
        )

    def validate_client_updated_at(self, value):
        from django.utils import timezone

        # A device with a wrong clock can otherwise pin a row permanently
        # ahead of every future edit and make it uneditable forever.
        if value > timezone.now() + timezone.timedelta(minutes=5):
            raise serializers.ValidationError(
                "client_updated_at is in the future; check the device clock."
            )
        return value

    def create(self, validated_data: dict) -> Bookmark:
        validated_data["user"] = self.context["request"].user
        return super().create(validated_data)
