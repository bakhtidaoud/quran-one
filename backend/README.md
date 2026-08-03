# Quran One API

Django 5.1 + DRF. PostgreSQL, Redis, Celery.

## Run it

```bash
cd backend
cp .env.example .env
docker compose up --build
docker compose exec api python manage.py migrate
docker compose exec api python manage.py createsuperuser
```

API at `http://localhost:8000/v1/`, docs at `/docs/`, admin at `/admin/`.

Without Docker:

```bash
python -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"
python manage.py migrate
python manage.py runserver
```

## Tests

```bash
pytest
pytest --cov=apps --cov-report=term-missing
```

## Layout

```
config/           settings split by environment, urls, celery, wsgi
apps/core/        abstract models, error envelope, pagination, logging
apps/accounts/    user, profile, JWT auth
apps/quran/       surahs, ayat, translations, reciters, bookmarks
apps/content/     content pack catalogue and signed downloads
apps/prayer/      calculation methods, regional defaults, mosques
apps/sync/        devices, hifz cards, positions, conflict resolution
apps/billing/     subscriptions, entitlement, store webhooks
```

## The four decisions that shape this codebase

**Prayer times are not an endpoint.** They are computed on the device from an
astronomical model. A prayer time that needs a network call fails on a plane,
in a basement, and in exactly the places with the most users and the worst
connectivity. The server holds only method definitions and regional defaults.

**Scripture is immutable.** `ImmutableModel.save` raises on any update to a
Surah or Ayah row, including from the admin. A correction is a new content
pack version, never an edit. There is a test for this and it is the most
important test in the repository.

**The client is authoritative, except for money.** Worship data syncs on the
client's terms; the server stores and redistributes it. Entitlement is the one
thing derived server-side from a validated store receipt, never from a client
claim.

**Nothing is hard-deleted.** Tombstones sync; absent rows do not. A bookmark
that vanishes from the server is indistinguishable, to a device that has been
offline for a week, from one that never existed.

## Privacy

Coordinates never leave the device. `apps/core/logging.py` redacts location,
email, tokens, note bodies and search queries before anything reaches a log
line or Sentry, and `send_default_pii` is off. Bookmark notes are excluded
from the admin: staff can see that a bookmark exists, never what it says.

## Error envelope

Every failure returns the same shape. The Flutter client maps `code` onto its
sealed `QFailure` hierarchy, so adding a code is a breaking change.

```json
{
  "error": {
    "code": "rate_limited",
    "message": "Request was throttled.",
    "trace_id": "9f2c...",
    "retry_after": 42
  }
}
```
