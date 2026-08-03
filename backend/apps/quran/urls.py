from rest_framework.routers import DefaultRouter

from .views import (
    AyahViewSet,
    BookmarkViewSet,
    ReciterViewSet,
    SurahViewSet,
    TranslationViewSet,
)

router = DefaultRouter()
router.register("surahs", SurahViewSet, basename="surah")
router.register("ayat", AyahViewSet, basename="ayah")
router.register("translations", TranslationViewSet, basename="translation")
router.register("reciters", ReciterViewSet, basename="reciter")
router.register("bookmarks", BookmarkViewSet, basename="bookmark")

urlpatterns = router.urls
