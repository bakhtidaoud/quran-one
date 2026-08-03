from django.conf import settings
from django.contrib import admin
from django.urls import include, path
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

from apps.core.views import health, readiness

# Versioning is in the path, not a header. A header-versioned API is one
# curl command away from an accidental breaking change.
v1_patterns = [
    path("auth/", include("apps.accounts.urls")),
    path("quran/", include("apps.quran.urls")),
    path("prayer/", include("apps.prayer.urls")),
    path("content/", include("apps.content.urls")),
    path("sync/", include("apps.sync.urls")),
    path("billing/", include("apps.billing.urls")),
]

urlpatterns = [
    path("admin/", admin.site.urls),
    path("healthz", health, name="health"),
    path("readyz", readiness, name="readiness"),
    path("v1/", include((v1_patterns, "v1"), namespace="v1")),
    path("schema/", SpectacularAPIView.as_view(), name="schema"),
    path(
        "docs/",
        SpectacularSwaggerView.as_view(url_name="schema"),
        name="docs",
    ),
]

if settings.DEBUG:  # pragma: no cover
    urlpatterns += [path("__debug__/", include("debug_toolbar.urls"))]
