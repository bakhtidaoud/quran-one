import pytest
from django.urls import reverse

pytestmark = pytest.mark.django_db


def test_the_surah_list_is_public(api, surah):
    response = api.get("/v1/quran/surahs/")

    # Scripture is never behind authentication. A person should be able to
    # read the Quran without an account, a subscription or a network
    # identity.
    assert response.status_code == 200
    assert response.data[0]["latin_name"] == "Al-Baqarah"


def test_a_range_query_without_a_surah_is_rejected(api, ayah):
    response = api.get("/v1/quran/ayat/?from=1&to=5")

    assert response.status_code == 400
    assert response.data["error"]["code"] == "validation_failed"


def test_a_page_outside_the_mushaf_is_rejected(api, ayah):
    response = api.get("/v1/quran/ayat/page/605/")

    assert response.status_code == 400


def test_bookmarks_require_authentication(api):
    response = api.get("/v1/quran/bookmarks/")

    assert response.status_code == 401
    assert response.data["error"]["code"] == "unauthorized"


def test_a_bookmark_with_a_future_clock_is_rejected(auth, ayah):
    from datetime import timedelta

    from django.utils import timezone

    response = auth.post(
        "/v1/quran/bookmarks/",
        {
            "ayah": ayah.pk,
            "client_updated_at": timezone.now() + timedelta(days=1),
        },
        format="json",
    )

    assert response.status_code == 400


def test_every_error_carries_a_trace_id(api):
    response = api.get("/v1/quran/bookmarks/", HTTP_X_REQUEST_ID="abc123")

    assert response.data["error"]["trace_id"] == "abc123"
    assert response["X-Request-ID"] == "abc123"
