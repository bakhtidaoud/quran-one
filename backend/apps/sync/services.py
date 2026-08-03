"""Conflict resolution.

One rule, applied consistently, with the losing version preserved:
last write wins by `client_updated_at`, except for Hifz cards, where the
more-progressed card wins regardless of clock.

The exception exists because clocks lie and memorisation progress is
monotonic in practice. A device with a clock skewed two hours forward must
not be able to erase a review that actually happened.
"""

from dataclasses import dataclass
from typing import Any

from django.db import transaction
from django.utils import timezone

from .models import HifzCard, SyncConflict


@dataclass(frozen=True)
class MergeOutcome:
    applied: int
    rejected: int
    conflicts: int


def merge_hifz_cards(user, payloads: list[dict[str, Any]]) -> MergeOutcome:
    applied = rejected = conflicts = 0

    with transaction.atomic():
        for payload in payloads:
            ayah_id = payload.get("ayah")
            incoming_at = payload.get("client_updated_at")
            if ayah_id is None or incoming_at is None:
                rejected += 1
                continue

            existing = (
                HifzCard.objects.select_for_update()
                .filter(user=user, ayah_id=ayah_id)
                .first()
            )

            if existing is None:
                HifzCard.objects.create(user=user, **payload)
                applied += 1
                continue

            if _incoming_wins(existing, payload):
                SyncConflict.objects.create(
                    user=user,
                    entity_type="hifz_card",
                    entity_id=str(existing.id),
                    losing_payload=_snapshot(existing),
                    winning_client_updated_at=incoming_at,
                    losing_client_updated_at=existing.client_updated_at,
                )
                for field, value in payload.items():
                    setattr(existing, field, value)
                existing.revision += 1
                existing.save()
                applied += 1
                conflicts += 1
            else:
                rejected += 1

    return MergeOutcome(applied, rejected, conflicts)


def _incoming_wins(existing: HifzCard, payload: dict[str, Any]) -> bool:
    # Progress beats recency. Losing a completed review is worse than
    # replaying one.
    incoming_reps = payload.get("repetitions", 0)
    if incoming_reps != existing.repetitions:
        return incoming_reps > existing.repetitions
    return payload["client_updated_at"] > existing.client_updated_at


def _snapshot(card: HifzCard) -> dict[str, Any]:
    return {
        "ease": card.ease,
        "interval_days": card.interval_days,
        "repetitions": card.repetitions,
        "lapses": card.lapses,
        "due_at": card.due_at.isoformat(),
        "client_updated_at": card.client_updated_at.isoformat(),
        "captured_at": timezone.now().isoformat(),
    }
