from rest_framework.routers import DefaultRouter

from .views import ContentPackViewSet

router = DefaultRouter()
router.register("packs", ContentPackViewSet, basename="pack")

urlpatterns = router.urls
