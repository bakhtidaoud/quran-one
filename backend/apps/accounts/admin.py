from django.contrib import admin

from .models import Profile, User


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ("email", "display_name", "is_active", "created_at")
    search_fields = ("email",)
    list_filter = ("is_active", "is_staff")
    readonly_fields = ("id", "created_at", "updated_at", "last_seen_at")


@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ("user", "locale", "calculation_method", "asr_method")
    search_fields = ("user__email",)
