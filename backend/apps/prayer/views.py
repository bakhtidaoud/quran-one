from django.utils.decorators import method_decorator
from django.views.decorators.cache import cache_page
from rest_framework import viewsets
from rest_framework.permissions import AllowAny

from .models import CalculationMethod, Mosque, RegionDefault
from .serializers import (
    CalculationMethodSerializer,
    MosqueSerializer,
    RegionDefaultSerializer,
)

WEEK = 60 * 60 * 24 * 7


@method_decorator(cache_page(WEEK), name="list")
class CalculationMethodViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = CalculationMethod.objects.filter(is_active=True)
    serializer_class = CalculationMethodSerializer
    permission_classes = [AllowAny]
    pagination_class = None


@method_decorator(cache_page(WEEK), name="list")
class RegionDefaultViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = RegionDefault.objects.select_related("method")
    serializer_class = RegionDefaultSerializer
    permission_classes = [AllowAny]
    pagination_class = None
    lookup_field = "country_code"


class MosqueViewSet(viewsets.ReadOnlyModelViewSet):
    """Only verified entries are ever served."""

    queryset = Mosque.objects.filter(is_verified=True)
    serializer_class = MosqueSerializer
    permission_classes = [AllowAny]
    filterset_fields = ["country_code", "city"]
