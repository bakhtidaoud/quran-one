import hashlib
import logging

from celery import shared_task
from django.core.files.storage import default_storage

from .models import ContentPackVersion

logger = logging.getLogger(__name__)


@shared_task(bind=True, max_retries=3, default_retry_delay=60)
def verify_published_packs(self) -> dict[str, int]:
    """Re-hashes every published pack against its recorded checksum.

    Storage corruption is rare and catastrophic: a single flipped bit in a
    Quran pack is a defect no amount of apology repairs. Nightly, cheap,
    worth it.
    """
    checked = 0
    failed = 0

    versions = ContentPackVersion.objects.filter(
        published_at__isnull=False, revoked_at__isnull=True
    )

    for version in versions.iterator(chunk_size=50):
        checked += 1
        digest = hashlib.sha256()
        try:
            with default_storage.open(version.object_key, "rb") as handle:
                for chunk in iter(lambda: handle.read(1024 * 1024), b""):
                    digest.update(chunk)
        except FileNotFoundError:
            failed += 1
            logger.error(
                "content pack object missing",
                extra={"context": {"pack": version.pack_id}},
            )
            continue

        if digest.hexdigest() != version.checksum:
            failed += 1
            logger.error(
                "content pack checksum mismatch",
                extra={"context": {"pack": version.pack_id}},
            )

    return {"checked": checked, "failed": failed}
