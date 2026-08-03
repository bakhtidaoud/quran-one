from rest_framework import serializers

from .models import Device, HifzCard, ReadingPosition


class DeviceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Device
        fields = ("id", "platform", "app_version", "push_token")


class HifzCardSerializer(serializers.ModelSerializer):
    class Meta:
        model = HifzCard
        fields = (
            "id",
            "ayah",
            "ease",
            "interval_days",
            "repetitions",
            "lapses",
            "due_at",
            "last_reviewed_at",
            "client_updated_at",
            "revision",
        )


class ReadingPositionSerializer(serializers.ModelSerializer):
    class Meta:
        model = ReadingPosition
        fields = ("mode", "surah", "ayah", "page", "client_updated_at")


class PushRequestSerializer(serializers.Serializer):
    """One round trip carries every entity type.

    Batching matters more than elegance here: the client is often on a slow
    connection with a short window, and six sequential requests is six
    chances to fail halfway.
    """

    device_id = serializers.CharField(max_length=64)
    bookmarks = serializers.ListField(child=serializers.DictField(), default=list)
    hifz_cards = serializers.ListField(child=serializers.DictField(), default=list)
    positions = serializers.ListField(child=serializers.DictField(), default=list)


class PullResponseSerializer(serializers.Serializer):
    server_time = serializers.DateTimeField()
    bookmarks = serializers.ListField(child=serializers.DictField())
    hifz_cards = HifzCardSerializer(many=True)
    positions = ReadingPositionSerializer(many=True)
    has_more = serializers.BooleanField()
