from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers


class ForgotPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()


class ResetPasswordSerializer(serializers.Serializer):
    token = serializers.CharField(max_length=128)
    password = serializers.CharField(write_only=True, max_length=128)

    def validate_password(self, value: str) -> str:
        validate_password(value)
        return value


class ChangePasswordSerializer(serializers.Serializer):
    current_password = serializers.CharField(write_only=True)
    password = serializers.CharField(write_only=True, max_length=128)

    def validate_password(self, value: str) -> str:
        validate_password(value, user=self.context["request"].user)
        return value


class VerifyEmailSerializer(serializers.Serializer):
    token = serializers.CharField(max_length=128)


class SessionSerializer(serializers.Serializer):
    id = serializers.UUIDField(read_only=True)
    device_name = serializers.CharField(read_only=True)
    platform = serializers.CharField(read_only=True)
    last_seen_at = serializers.DateTimeField(read_only=True)
    # City, never the IP itself. City answers "was this me?"; a stored IP
    # against religious activity is a record nobody should be holding.
    location = serializers.CharField(read_only=True, allow_null=True)
    is_current = serializers.BooleanField(read_only=True)
