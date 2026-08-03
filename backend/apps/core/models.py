"""Abstract bases. Nothing here creates a table."""

import uuid

from django.db import models


class UUIDModel(models.Model):
    """Client-generatable primary keys.

    The app writes offline and syncs later, so the client must be able to
    mint an id that will still be unique when it finally reaches the server.
    A sequential integer cannot do that.
    """

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    class Meta:
        abstract = True


class TimestampedModel(models.Model):
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True


class SoftDeleteQuerySet(models.QuerySet["SoftDeleteModel"]):
    def alive(self) -> "SoftDeleteQuerySet":
        return self.filter(deleted_at__isnull=True)


class SoftDeleteModel(models.Model):
    """Tombstones, not deletions.

    A hard delete cannot be synced. If a bookmark disappears from the server
    a client that has been offline for a week has no way to tell deletion
    apart from never-having-existed, and will happily resurrect it.
    """

    deleted_at = models.DateTimeField(null=True, blank=True, db_index=True)

    objects = SoftDeleteQuerySet.as_manager()

    class Meta:
        abstract = True

    @property
    def is_deleted(self) -> bool:
        return self.deleted_at is not None
