from django.utils import timezone
from drf_spectacular.utils import extend_schema
from rest_framework import serializers, status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Subscription, WebhookEvent


class EntitlementSerializer(serializers.Serializer):
    is_premium = serializers.BooleanField()
    expires_at = serializers.DateTimeField(allow_null=True)
    platform = serializers.CharField(allow_null=True)
    in_grace_period = serializers.BooleanField()


class EntitlementView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(responses=EntitlementSerializer)
    def get(self, request: Request) -> Response:
        sub = (
            Subscription.objects.filter(
                user=request.user, is_active=True, expires_at__gt=timezone.now()
            )
            .order_by("-expires_at")
            .first()
        )

        return Response(
            EntitlementSerializer(
                {
                    "is_premium": sub is not None,
                    "expires_at": sub.expires_at if sub else None,
                    "platform": sub.platform if sub else None,
                    "in_grace_period": sub.in_grace_period if sub else False,
                }
            ).data
        )


class StoreWebhookView(APIView):
    """Stores an event and returns immediately.

    Processing happens in a Celery task. A store that does not get a fast
    2xx retries, and retrying a slow synchronous handler turns one problem
    into a queue of them.
    """

    permission_classes = [AllowAny]
    authentication_classes = ()

    def post(self, request: Request, platform: str) -> Response:
        event_id = request.data.get("eventId") or request.data.get("id", "")
        if not event_id:
            return Response(
                {"detail": "Missing event id"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        WebhookEvent.objects.get_or_create(
            platform=platform,
            event_id=str(event_id),
            defaults={"payload": request.data},
        )

        return Response(status=status.HTTP_202_ACCEPTED)
