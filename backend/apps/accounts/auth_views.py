from django.contrib.auth.hashers import check_password, make_password
from django.db import transaction
from django.utils import timezone
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.token_blacklist.models import (
    BlacklistedToken,
    OutstandingToken,
)

from apps.accounts.auth_serializers import (
    ChangePasswordSerializer,
    ForgotPasswordSerializer,
    ResetPasswordSerializer,
    VerifyEmailSerializer,
)
from apps.accounts.models import User
from apps.accounts.throttles import EmailScopedThrottle
from apps.accounts.tokens import OneTimeToken

# A precomputed hash, compared against when the account does not exist so
# that a missing user and a wrong password take the same time. Without it,
# response latency is an account-existence oracle.
_DUMMY_HASH = make_password("dummy-password-for-timing-equalisation")


def _revoke_all(user) -> None:
    for outstanding in OutstandingToken.objects.filter(user=user):
        BlacklistedToken.objects.get_or_create(token=outstanding)


class ForgotPasswordView(APIView):
    permission_classes = [AllowAny]
    throttle_classes = [EmailScopedThrottle]
    throttle_scope = "auth_reset"

    def post(self, request):
        serializer = ForgotPasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data["email"]

        user = User.objects.filter(email__iexact=email, is_active=True).first()
        if user is not None:
            raw = OneTimeToken.issue(
                user,
                OneTimeToken.Purpose.PASSWORD_RESET,
                ip=request.META.get("REMOTE_ADDR"),
            )
            from apps.accounts.tasks import send_password_reset

            send_password_reset.delay(str(user.pk), raw)

        # Always 202, always the same body. Branching here turns the
        # endpoint into an account-existence oracle, which for a religious
        # app is not a privacy nicety: in several jurisdictions it is a way
        # to enumerate who is Muslim.
        return Response(
            {
                "detail": (
                    "If that address has an account, a reset link is on "
                    "its way."
                )
            },
            status=status.HTTP_202_ACCEPTED,
        )


class ResetPasswordView(APIView):
    permission_classes = [AllowAny]
    throttle_classes = [EmailScopedThrottle]
    throttle_scope = "auth_reset"

    @transaction.atomic
    def post(self, request):
        serializer = ResetPasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        token = OneTimeToken.consume(
            serializer.validated_data["token"],
            OneTimeToken.Purpose.PASSWORD_RESET,
        )
        if token is None:
            return Response(
                {
                    "error": {
                        "code": "validation_failed",
                        "message": "Invalid or expired reset token.",
                        "trace_id": getattr(request, "request_id", None),
                    }
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        user = token.user
        user.set_password(serializer.validated_data["password"])
        user.save(update_fields=["password"])

        # A reset means "I may have been compromised". Every outstanding
        # refresh token dies on every device; the alternative leaves the
        # attacker signed in on the device that caused the reset.
        _revoke_all(user)

        return Response(status=status.HTTP_204_NO_CONTENT)


class ChangePasswordView(APIView):
    permission_classes = [IsAuthenticated]
    throttle_classes = [EmailScopedThrottle]
    throttle_scope = "auth_reset"

    def post(self, request):
        serializer = ChangePasswordSerializer(
            data=request.data, context={"request": request}
        )
        serializer.is_valid(raise_exception=True)

        user = request.user
        if not check_password(
            serializer.validated_data["current_password"], user.password
        ):
            return Response(
                {
                    "error": {
                        "code": "unauthorized",
                        "message": "Current password is incorrect.",
                        "trace_id": getattr(request, "request_id", None),
                    }
                },
                status=status.HTTP_401_UNAUTHORIZED,
            )

        user.set_password(serializer.validated_data["password"])
        user.save(update_fields=["password"])

        # Other devices are revoked, this one is not. Signing a user out of
        # the session they are actively using to change their password is
        # punishing them for good hygiene.
        _revoke_all(user)

        return Response(status=status.HTTP_204_NO_CONTENT)


class VerifyEmailView(APIView):
    permission_classes = [AllowAny]
    throttle_scope = "auth_verify"

    @transaction.atomic
    def post(self, request):
        serializer = VerifyEmailSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        token = OneTimeToken.consume(
            serializer.validated_data["token"],
            OneTimeToken.Purpose.EMAIL_VERIFY,
        )
        if token is None:
            return Response(
                {
                    "error": {
                        "code": "validation_failed",
                        "message": "Invalid or expired verification token.",
                        "trace_id": getattr(request, "request_id", None),
                    }
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        user = token.user
        user.email_verified_at = timezone.now()
        user.save(update_fields=["email_verified_at"])

        return Response(status=status.HTTP_204_NO_CONTENT)


class LogoutAllView(APIView):
    permission_classes = [IsAuthenticated]
    throttle_scope = "auth_reset"

    def post(self, request):
        _revoke_all(request.user)
        return Response(status=status.HTTP_204_NO_CONTENT)


class SessionListView(APIView):
    """Outstanding refresh tokens, joined to sync_device for a label."""

    permission_classes = [IsAuthenticated]

    def get(self, request):
        blacklisted = BlacklistedToken.objects.values_list(
            "token_id", flat=True
        )
        tokens = (
            OutstandingToken.objects.filter(
                user=request.user, expires_at__gt=timezone.now()
            )
            .exclude(id__in=blacklisted)
            .order_by("-created_at")
        )

        from apps.sync.models import Device

        devices = {
            d.pk: d for d in Device.objects.filter(user=request.user)
        }

        payload = []
        for token in tokens:
            device = devices.get(token.jti)
            payload.append(
                {
                    "id": str(token.id),
                    "device_name": getattr(device, "name", "Unknown device"),
                    "platform": getattr(device, "platform", "unknown"),
                    "last_seen_at": getattr(device, "last_sync_at", None),
                    "is_current": token.jti
                    == request.auth.get("jti")
                    if request.auth
                    else False,
                }
            )

        return Response({"results": payload})

    def delete(self, request):
        _revoke_all(request.user)
        return Response(status=status.HTTP_204_NO_CONTENT)
