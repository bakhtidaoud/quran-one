import pytest
from django.core.exceptions import ValidationError
from django.utils import timezone

from apps.content.models import ContentPack, ContentPackVersion

pytestmark = pytest.mark.django_db


@pytest.fixture
def pack(db) -> ContentPack:
    return ContentPack.objects.create(
        id="quran.uthmani",
        kind=ContentPack.QURAN_TEXT,
        name="Uthmani text",
    )


def test_a_published_version_cannot_be_rewritten(pack):
    version = ContentPackVersion.objects.create(
        pack=pack,
        version=1,
        object_key="packs/quran.uthmani/1.bin",
        size_bytes=1024,
        checksum="a" * 64,
        published_at=timezone.now(),
    )

    version.object_key = "packs/somewhere-else.bin"

    # Two devices must never be able to hold different bytes while both
    # believe they are on version 1.
    with pytest.raises(ValidationError):
        version.save()


def test_a_published_version_can_still_be_revoked(pack):
    version = ContentPackVersion.objects.create(
        pack=pack,
        version=1,
        object_key="packs/quran.uthmani/1.bin",
        size_bytes=1024,
        checksum="a" * 64,
        published_at=timezone.now(),
    )

    version.revoked_at = timezone.now()
    version.save(update_fields=["revoked_at"])

    version.refresh_from_db()
    assert version.revoked_at is not None


def test_a_checksum_must_be_a_sha256_digest(pack):
    version = ContentPackVersion(
        pack=pack,
        version=2,
        object_key="packs/quran.uthmani/2.bin",
        size_bytes=1,
        checksum="too-short",
    )

    with pytest.raises(ValidationError):
        version.clean()


def test_an_unpublished_pack_has_no_download(api, pack):
    response = api.post("/v1/content/packs/quran.uthmani/download/")

    assert response.status_code == 404


def test_a_premium_pack_refuses_an_anonymous_download(api, db):
    ContentPack.objects.create(
        id="tafsir.ibn-kathir",
        kind=ContentPack.TAFSIR,
        name="Ibn Kathir",
        is_premium=True,
    )

    response = api.post("/v1/content/packs/tafsir.ibn-kathir/download/")

    assert response.status_code in (401, 403)
