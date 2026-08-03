from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers

from .models import Profile, User


class ProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = Profile
        fields = (
            "locale",
            "calculation_method",
            "asr_method",
            "translation_pack_ids",
            "reciter_id",
            "analytics_opt_in",
        )


class UserSerializer(serializers.ModelSerializer):
    profile = ProfileSerializer(read_only=True)

    class Meta:
        model = User
        fields = ("id", "email", "display_name", "created_at", "profile")
        read_only_fields = ("id", "email", "created_at")


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(
        write_only=True, validators=[validate_password], style={"input_type": "password"}
    )

    class Meta:
        model = User
        fields = ("email", "password", "display_name")

    def create(self, validated_data: dict) -> User:
        user = User.objects.create_user(**validated_data)
        Profile.objects.create(user=user)
        return user


class DeleteAccountSerializer(serializers.Serializer):
    confirm = serializers.BooleanField()

    def validate_confirm(self, value: bool) -> bool:
        if not value:
            raise serializers.ValidationError("Deletion must be confirmed.")
        return value
