from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.utils import timezone

from apps.core.models import TimestampedModel, UUIDModel


class UserManager(BaseUserManager["User"]):
    use_in_migrations = True

    def create_user(self, email: str, password: str | None = None, **extra):
        if not email:
            raise ValueError("An email address is required")
        user = self.model(email=self.normalize_email(email), **extra)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email: str, password: str, **extra):
        extra.setdefault("is_staff", True)
        extra.setdefault("is_superuser", True)
        extra.setdefault("is_active", True)
        return self.create_user(email, password, **extra)


class User(UUIDModel, TimestampedModel, AbstractBaseUser, PermissionsMixin):
    """Email is the identifier. There is no username.

    An account is optional in this product. Everything except sync and
    billing works without one, so this table is smaller than the install
    base by design.
    """

    email = models.EmailField(unique=True, db_index=True)
    display_name = models.CharField(max_length=80, blank=True)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    last_seen_at = models.DateTimeField(null=True, blank=True)
    deletion_requested_at = models.DateTimeField(null=True, blank=True)

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS: list[str] = []

    objects = UserManager()

    class Meta:
        db_table = "accounts_user"
        indexes = [models.Index(fields=["deletion_requested_at"])]

    def __str__(self) -> str:
        return self.email

    def touch(self) -> None:
        # Day granularity. Storing exact last-seen timestamps for a worship
        # app builds a prayer-habit profile nobody asked for.
        today = timezone.now().date()
        if self.last_seen_at is None or self.last_seen_at.date() != today:
            self.last_seen_at = timezone.now()
            self.save(update_fields=["last_seen_at"])


class Profile(TimestampedModel):
    """Worship preferences that must survive a reinstall.

    Deliberately does NOT hold location. Coordinates stay on the device;
    prayer times are computed there.
    """

    ASR_STANDARD = "standard"
    ASR_HANAFI = "hanafi"

    user = models.OneToOneField(
        "accounts.User", on_delete=models.CASCADE, related_name="profile"
    )
    locale = models.CharField(max_length=10, default="en")
    calculation_method = models.CharField(
        max_length=40, default="muslim_world_league"
    )
    asr_method = models.CharField(
        max_length=10,
        default=ASR_STANDARD,
        choices=[(ASR_STANDARD, "Standard"), (ASR_HANAFI, "Hanafi")],
    )
    translation_pack_ids = models.JSONField(default=list, blank=True)
    reciter_id = models.CharField(max_length=40, blank=True)
    analytics_opt_in = models.BooleanField(default=False)

    class Meta:
        db_table = "accounts_profile"

    def __str__(self) -> str:
        return f"Profile<{self.user_id}>"
