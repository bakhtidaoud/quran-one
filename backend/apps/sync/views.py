from django.utils import timezone
from drf_spectacular.utils import extend_schema
from rest_framework import status, viewsets
from rest_framework.permissions import IsAuthenticated
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.quran.models import Bookmark
from apps.quran.serializers import BookmarkSerializer

from .models import Device, HifzCard, ReadingPosition
from .serializers import (
    DeviceSerializer,
    HifzCardSerializer,
    PullResponseSerializer,
    PushRequestSerializer,
    ReadingPositionSerializer,
)
from .services import merge_hifz_cards

PULL_LIMIT = 500


class DeviceViewSet(viewsets.ModelViewSet):
    serializer_class = DeviceSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Device.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class PushView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(request=PushRequestSerializer, responses={200: None})
    def post(self, request: Request) -> Response:
        serializer = PushRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        outcome = merge_hifz_cards(request.user, data["hifz_cards"])

        Device.objects.filter(
            id=data["device_id"], user=request.user
        ).update(last_sync_at=timezone.now())

        return Response(
            {
                "hifz": {
                    "applied": outcome.applied,
                    "rejected": outcome.rejected,
                    "conflicts": outcome.conflicts,
                },
                "server_time": timezone.now(),
            },
            status=status.HTTP_200_OK,
        )


class PullView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(responses=PullResponseSerializer)
    def get(self, request: Request) -> Response:
        since = request.query_params.get("since")
        user = request.user

        bookmarks = Bookmark.objects.filter(user=user)
        cards = HifzCard.objects.filter(user=user)
        positions = ReadingPosition.objects.filter(user=user)

        if since:
            bookmarks = bookmarks.filter(client_updated_at__gt=since)
            cards = cards.filter(client_updated_at__gt=since)
            positions = positions.filter(client_updated_at__gt=since)

        card_page = list(cards.order_by("client_updated_at")[: PULL_LIMIT + 1])
        has_more = len(card_page) > PULL_LIMIT

        return Response(
            PullResponseSerializer(
                {
                    "server_time": timezone.now(),
                    "bookmarks": BookmarkSerializer(
                        bookmarks[:PULL_LIMIT], many=True
                    ).data,
                    "hifz_cards": card_page[:PULL_LIMIT],
                    "positions": positions,
                    "has_more": has_more,
                }
            ).data
        )
