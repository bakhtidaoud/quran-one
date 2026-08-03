from rest_framework.routers import DefaultRouter

from .views import CalculationMethodViewSet, MosqueViewSet, RegionDefaultViewSet

router = DefaultRouter()
router.register("methods", CalculationMethodViewSet, basename="method")
router.register("regions", RegionDefaultViewSet, basename="region")
router.register("mosques", MosqueViewSet, basename="mosque")

urlpatterns = router.urls
