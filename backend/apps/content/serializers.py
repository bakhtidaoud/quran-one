from rest_framework import serializers

from .models import ContentPack, ContentPackVersion


class ContentPackVersionSerializer(serializers.ModelSerializer):
    class Meta:
        model = ContentPackVersion
        fields = (
            "version",
            "size_bytes",
            "checksum",
            "signature",
            "published_at",
            "changelog",
        )


class ContentPackSerializer(serializers.ModelSerializer):
    latest = serializers.SerializerMethodField()

    class Meta:
        model = ContentPack
        fields = (
            "id",
            "kind",
            "name",
            "language",
            "is_premium",
            "min_app_version",
            "latest",
        )

    def get_latest(self, obj: ContentPack) -> dict | None:
        version = (
            obj.versions.filter(
                published_at__isnull=False, revoked_at__isnull=True
            )
            .order_by("-version")
            .first()
        )
        if version is None:
            return None
        return ContentPackVersionSerializer(version).data


class DownloadUrlSerializer(serializers.Serializer):
    url = serializers.URLField()
    expires_in = serializers.IntegerField()
    checksum = serializers.CharField()
    size_bytes = serializers.IntegerField()
