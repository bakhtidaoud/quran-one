import pytest
from django.utils import timezone
from rest_framework.test import APIClient

from apps.accounts.models import Profile, User
from apps.quran.models import Ayah, Surah


@pytest.fixture
def api() -> APIClient:
    return APIClient()


@pytest.fixture
def user(db) -> User:
    account = User.objects.create_user(
        email="reader@example.com", password="not-a-real-password"
    )
    Profile.objects.create(user=account)
    return account


@pytest.fixture
def auth(api: APIClient, user: User) -> APIClient:
    api.force_authenticate(user=user)
    return api


@pytest.fixture
def surah(db) -> Surah:
    return Surah.objects.create(
        number=2,
        arabic_name="",
        latin_name="Al-Baqarah",
        english_name="The Cow",
        ayah_count=286,
        revelation=Surah.MEDINAN,
        revelation_order=87,
        start_page=2,
    )


@pytest.fixture
def ayah(surah: Surah) -> Ayah:
    return Ayah.objects.create(
        id=262,
        surah=surah,
        number=255,
        uthmani="...",
        simple="...",
        juz=3,
        hizb=5,
        rub=1,
        page=42,
        ruku=34,
        manzil=1,
    )


@pytest.fixture
def now():
    return timezone.now()
