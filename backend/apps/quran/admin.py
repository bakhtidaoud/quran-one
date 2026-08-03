from django.contrib import admin

from .models import Ayah, Bookmark, Reciter, Surah, Translation


@admin.register(Surah)
class SurahAdmin(admin.ModelAdmin):
    list_display = ("number", "latin_name", "ayah_count", "revelation")
    # Scripture is read-only in the admin too. There is no legitimate reason
    # for a staff member to hand-edit an ayah.
    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False


@admin.register(Ayah)
class AyahAdmin(SurahAdmin):
    list_display = ("id", "surah", "number", "juz", "page", "sajdah")
    list_filter = ("juz", "sajdah")
    search_fields = ("simple",)


@admin.register(Translation)
class TranslationAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "language", "license_expires_at", "is_active")
    list_filter = ("language", "is_active")


@admin.register(Reciter)
class ReciterAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "style", "riwayah", "is_active")


@admin.register(Bookmark)
class BookmarkAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "ayah", "deleted", "client_updated_at")
    # Notes are private religious reflection. Staff can see that a bookmark
    # exists, never what it says.
    exclude = ("note",)
