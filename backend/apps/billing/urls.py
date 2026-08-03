from django.urls import path

from .views import EntitlementView, StoreWebhookView

urlpatterns = [
    path("entitlement", EntitlementView.as_view(), name="entitlement"),
    path(
        "webhook/<str:platform>",
        StoreWebhookView.as_view(),
        name="store-webhook",
    ),
]
