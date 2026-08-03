from django.urls import path
from rest_framework.routers import DefaultRouter

from .views import DeviceViewSet, PullView, PushView

router = DefaultRouter()
router.register("devices", DeviceViewSet, basename="device")

urlpatterns = [
    path("push", PushView.as_view(), name="sync-push"),
    path("pull", PullView.as_view(), name="sync-pull"),
    *router.urls,
]
