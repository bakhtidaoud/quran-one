from django.contrib import admin

from .models import ContentPack, ContentPackVersion


class VersionInline(admin.TabularInline):
    model = ContentPackVersion
    extra = 0
    readonly_fields = ("checksum", "size_bytes", "published_at")


@admin.register(ContentPack)
class ContentPackAdmin(admin.ModelAdmin):
    list_display = ("id", "kind", "language", "is_premium", "is_active")
    list_filter = ("kind", "is_premium", "is_active")
    inlines = [VersionInline]


@admin.register(ContentPackVersion)
class ContentPackVersionAdmin(admin.ModelAdmin):
    list_display = ("pack", "version", "published_at", "revoked_at")
    list_filter = ("pack__kind",)
