from datetime import timedelta

import pytest
from django.utils import timezone

from apps.quran.models import Ayah
from apps.sync.models import HifzCard, SyncConflict
from apps.sync.services import merge_hifz_cards

pytestmark = pytest.mark.django_db


def _card(user, ayah: Ayah, **overrides) -> HifzCard:
    defaults = {
        "user": user,
        "ayah": ayah,
        "repetitions": 5,
        "interval_days": 10,
        "due_at": timezone.now() + timedelta(days=10),
        "client_updated_at": timezone.now(),
    }
    return HifzCard.objects.create(**{**defaults, **overrides})


def test_a_new_card_is_created(user, ayah):
    outcome = merge_hifz_cards(
        user,
        [
            {
                "ayah": ayah.pk,
                "repetitions": 1,
                "interval_days": 1,
                "due_at": timezone.now(),
                "client_updated_at": timezone.now(),
            }
        ],
    )

    assert outcome.applied == 1
    assert HifzCard.objects.count() == 1


def test_more_progress_wins_over_a_newer_timestamp(user, ayah):
    existing = _card(user, ayah, repetitions=12)

    outcome = merge_hifz_cards(
        user,
        [
            {
                "ayah": ayah.pk,
                "repetitions": 3,
                # Newer clock, less progress. A device with a skewed clock
                # must not be able to erase nine completed reviews.
                "client_updated_at": timezone.now() + timedelta(hours=2),
            }
        ],
    )

    existing.refresh_from_db()
    assert outcome.rejected == 1
    assert existing.repetitions == 12


def test_the_losing_version_is_preserved(user, ayah):
    _card(user, ayah, repetitions=2)

    merge_hifz_cards(
        user,
        [
            {
                "ayah": ayah.pk,
                "repetitions": 9,
                "client_updated_at": timezone.now(),
            }
        ],
    )

    # Last write wins, but the discarded version is recoverable. This is the
    # difference between a sync bug and permanent loss.
    conflict = SyncConflict.objects.get()
    assert conflict.losing_payload["repetitions"] == 2


def test_the_revision_counter_increments_on_every_merge(user, ayah):
    card = _card(user, ayah, repetitions=1)

    merge_hifz_cards(
        user,
        [
            {
                "ayah": ayah.pk,
                "repetitions": 4,
                "client_updated_at": timezone.now(),
            }
        ],
    )

    card.refresh_from_db()
    assert card.revision == 2


def test_a_malformed_payload_is_rejected_not_crashed(user, ayah):
    outcome = merge_hifz_cards(user, [{"repetitions": 3}])

    assert outcome.rejected == 1
    assert HifzCard.objects.count() == 0
