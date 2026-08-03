from django.core.files.storage import default_storage
from django.utils import timezone
from drf_spectacular.utils import extend_schema
from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.exceptions import NotFound, PermissionDenied
from rest_framework.permissions import AllowAny
from rest_framework.request import Request
from rest_framework.response import Response

from .models import ContentPack, ContentPackVersion
from .serializers import (
    ContentPackSerializer,
    DownloadUrlSerializer,
)


class ContentPackViewSet(viewsets.ReadOnlyModelViewSet):
    """The catalogue is public. The bytes are not necessarily."""

    queryset = ContentPack.objects.filter(is_active=True).prefetch_related(
        "versions"
    )
    serializer_class = ContentPackSerializer
    permission_classes = [AllowAny]
    filterset_fields = ["kind", "language", "is_premium"]
    pagination_class = None

    @extend_schema(responses=DownloadUrlSerializer)
    @action(detail=True, methods=["post"], url_path="download")
    def download(self, request: Request, pk: str) -> Response:
        pack = self.get_object()

        if pack.is_premium:
            user = request.user
            if user is None or not user.is_authenticated:
                raise PermissionDenied("Sign in to download this pack.")
            if not _has_active_subscription(user):
                raise PermissionDenied("This pack requires a subscription.")

        version = (
            ContentPackVersion.objects.filter(
                pack=pack,
                published_at__isnull=False,
                published_at__lte=timezone.now(),
                revoked_at__isnull=True,
            )
            .order_by("-version")
            .first()
        )
        if version is None:
            raise NotFound("No published version for this pack.")

        # Signed, short-lived, single object. The client verifies the
        # checksum after download and discards the file if it disagrees.
        url = default_storage.url(version.object_key)

        return Response(
            DownloadUrlSerializer(
                {
                    "url": url,
                    "expires_in": 3600,
                    "checksum": version.checksum,
                    "size_bytes": version.size_bytes,
                }
            ).data
        )


def _has_active_subscription(user) -> bool:
    from apps.billing.models import Subscription

    return Subscription.objects.filter(user=user, is_active=True).exists()
