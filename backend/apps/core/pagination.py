from rest_framework.pagination import CursorPagination as DRFCursorPagination


class CursorPagination(DRFCursorPagination):
    """Cursor, not offset.

    Offset pagination on a table that receives writes during the walk skips
    and duplicates rows. For a sync endpoint that is data loss, not a
    cosmetic bug.
    """

    page_size = 50
    max_page_size = 200
    page_size_query_param = "page_size"
    ordering = "-created_at"


class SyncPagination(CursorPagination):
    """Sync walks forward through updated_at, oldest first."""

    page_size = 200
    max_page_size = 500
    ordering = "updated_at"
