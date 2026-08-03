from django.db.models import QuerySet
from django.utils.decorators import method_decorator
from django.views.decorators.cache import cache_page
from django.views.decorators.vary import vary_on_headers
from drf_spectacular.utils import extend_schema, extend_schema_view
from rest_framework import mixins, viewsets
from rest_framework.decorators import action
from rest_framework.exceptions import ValidationError
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.request import Request
from rest_framework.response import Response

from .models import Ayah, Bookmark, Reciter, Surah, Translation
from .serializers import (
    AyahSerializer,
    BookmarkSerializer,
    ReciterSerializer,
    SurahSerializer,
    TranslationSerializer,
)

DAY = 60 * 60 * 24


@method_decorator(cache_page(DAY * 30), name="list")
@method_decorator(cache_page(DAY * 30), name="retrieve")
class SurahViewSet(viewsets.ReadOnlyModelViewSet):
    """Public and heavily cached. This response has not changed in 1400 years."""

    queryset = Surah.objects.all()
    serializer_class = SurahSerializer
    permission_classes = [AllowAny]
    pagination_class = None


@method_decorator(vary_on_headers("Accept-Language"), name="list")
class AyahViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Ayah.objects.select_related("surah")
    serializer_class = AyahSerializer
    permission_classes = [AllowAny]
    filterset_fields = ["surah", "juz", "page"]

    def get_queryset(self) -> QuerySet[Ayah]:
        qs = super().get_queryset()
        surah = self.request.query_params.get("surah")
        from_ayah = self.request.query_params.get("from")
        to_ayah = self.request.query_params.get("to")

        if from_ayah and to_ayah:
            if not surah:
                raise ValidationError(
                    {"surah": "A range query requires a surah."}
                )
            qs = qs.filter(number__gte=from_ayah, number__lte=to_ayah)

        return qs

    @extend_schema(responses=AyahSerializer(many=True))
    @action(detail=False, url_path="page/(?P<page_number>[0-9]+)")
    def by_page(self, request: Request, page_number: str) -> Response:
        number = int(page_number)
        if not 1 <= number <= 604:
            raise ValidationError({"page": "Pages run from 1 to 604."})
        ayat = self.get_queryset().filter(page=number)
        return Response(self.get_serializer(ayat, many=True).data)


@extend_schema_view(list=extend_schema(description="Active translation works."))
class TranslationViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Translation.objects.filter(is_active=True)
    serializer_class = TranslationSerializer
    permission_classes = [AllowAny]
    filterset_fields = ["language"]
    pagination_class = None


class ReciterViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Reciter.objects.filter(is_active=True)
    serializer_class = ReciterSerializer
    permission_classes = [AllowAny]
    pagination_class = None


class BookmarkViewSet(
    mixins.CreateModelMixin,
    mixins.RetrieveModelMixin,
    mixins.UpdateModelMixin,
    mixins.ListModelMixin,
    viewsets.GenericViewSet,
):
    """No destroy action, on purpose.

    Deleting is `PATCH deleted=true`. A tombstone syncs; an absent row does
    not.
    """

    serializer_class = BookmarkSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self) -> QuerySet[Bookmark]:
        qs = Bookmark.objects.filter(user=self.request.user)
        since = self.request.query_params.get("since")
        if since:
            qs = qs.filter(client_updated_at__gt=since)
        return qs.select_related("ayah")
