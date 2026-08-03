import pytest
from django.core.exceptions import PermissionDenied

from apps.quran.models import Ayah

pytestmark = pytest.mark.django_db


def test_an_ayah_cannot_be_edited(ayah: Ayah):
    ayah.uthmani = "tampered"

    # This is the most important test in the backend. There is no code path,
    # admin action or migration convenience that may rewrite scripture in
    # place. Corrections ship as a new content pack version.
    with pytest.raises(PermissionDenied):
        ayah.save()


def test_an_ayah_cannot_be_deleted(ayah: Ayah):
    with pytest.raises(PermissionDenied):
        ayah.delete()


def test_the_seeder_may_write_with_an_explicit_flag(ayah: Ayah):
    ayah.uthmani = "corrected by content pack v2"
    ayah.save(allow_scripture_write=True)

    ayah.refresh_from_db()
    assert ayah.uthmani == "corrected by content pack v2"
