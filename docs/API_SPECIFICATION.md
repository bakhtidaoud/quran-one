# Quran One - REST API Specification

- **Base URL:** `https://api.quranone.app/v1`
- **Content type:** `application/json; charset=utf-8`
- **Spec:** OpenAPI 3.1, published at `/v1/openapi.json`

---

## 0. Global conventions

### 0.1 Versioning

| Aspect | Policy |
| --- | --- |
| Scheme | URL path major version: `/v1/`, `/v2/` |
| Minor changes | Additive only, no version bump. Clients must ignore unknown fields. |
| Breaking change | New major version. Both run concurrently. |
| Deprecation window | 18 months minimum from `/v2` GA to `/v1` shutdown |
| Signalling | `Sunset:` and `Deprecation: true` headers |
| Content version | Independent of API version, via `X-Content-Version: 2026.07.3` |

Why 18 months and not the usual 6: a meaningful share of users are on devices that will never update again, in markets with expensive data. Breaking the API on a phone that still opens the mushaf every morning is a failure of the product's promise. The Quran read path and prayer config endpoints are frozen contracts and will not receive a breaking change in v1's lifetime.

### 0.2 Authentication

| Type | Header | Used by | Lifetime |
| --- | --- | --- | --- |
| Firebase ID token | `Authorization: Bearer <jwt>` | All authenticated calls | 60 min |
| Anonymous token | `Authorization: Bearer <jwt>` | Pre-signup users | 60 min |
| No auth | - | Content endpoints | - |

Every request also sends `X-Device-Id`, `X-App-Version`, `X-Platform`, `Accept-Language`.

Auth requirement notation:

- `PUBLIC` - no token
- `ANON` - any valid token, including anonymous
- `USER` - non-anonymous token
- `PROFILE` - `USER` plus `X-Profile-Id` header, RLS-scoped
- `ADMIN` - staff role claim

### 0.3 Error format (RFC 9457 Problem Details)

```json
{
  "type": "https://api.quranone.app/errors/validation-failed",
  "title": "Validation failed",
  "status": 422,
  "detail": "grade must be between 0 and 5",
  "instance": "/v1/hifz/attempts",
  "trace_id": "01J3K7X2QW8N4E5R6T7Y8U9I0P",
  "errors": [
    { "field": "attempts[3].grade", "code": "out_of_range", "message": "must be 0-5" }
  ]
}
```

| Status | Code family |
| --- | --- |
| 400 | `malformed_request` |
| 401 | `token_expired`, `token_invalid`, `token_revoked` |
| 403 | `insufficient_scope`, `profile_mismatch`, `region_unavailable` |
| 404 | `not_found` |
| 409 | `conflict`, `revision_stale`, `duplicate_resource` |
| 410 | `content_version_retired` |
| 422 | `validation_failed` |
| 423 | `account_locked` |
| 429 | `rate_limited` (with `Retry-After`) |
| 451 | `content_unavailable_in_region` |
| 500 / 503 | `internal_error`, `service_unavailable` |

`trace_id` is present on every error response including 500s, and is shown to users in the diagnostics screen. A user reporting "Athan did not fire" with a trace ID is worth ten reports without one.

### 0.4 Pagination

Cursor-based everywhere. Offset pagination is not offered on any endpoint.

```http
GET /v1/hadith/collections/bukhari/narrations?limit=25&cursor=eyJpZCI6MTIzfQ
```

```json
{
  "data": [],
  "pagination": {
    "next_cursor": "eyJpZCI6MTQ4fQ",
    "prev_cursor": "eyJpZCI6MTAxfQ",
    "has_more": true,
    "limit": 25
  }
}
```

| Rule | Value |
| --- | --- |
| Default limit | 25 |
| Max limit | 100 (200 for sync deltas) |
| Cursor | Opaque base64 keyset, never a row offset |
| Stability | Valid across inserts, no skipped or duplicated rows |
| Total counts | Not returned by default, `?include_total=true` on small collections |

Sync endpoints use revision-based pagination (`?since_revision=8842`) because a sync cursor must survive weeks of offline time, which an opaque keyset cursor cannot guarantee.

### 0.5 Filtering, sorting, sparse fieldsets

```http
GET /v1/quran/ayahs?juz=30&sajdah=true&fields=ayah_id,text_uthmani,page_number
GET /v1/bookmarks?folder_id=<uuid>&created_after=2026-01-01T00:00:00Z&sort=-created_at
GET /v1/hadith/narrations?grade=sahih&topic=prayer&collection=bukhari,muslim
```

| Convention | Form |
| --- | --- |
| Equality | `?status=active` |
| Multi-value OR | `?collection=bukhari,muslim` |
| Ranges | `?created_after=`, `?ayah_from=`, `?ayah_to=` |
| Sort | `?sort=-created_at,title` |
| Sparse fields | `?fields=a,b,c` |
| Expansion | `?expand=translation,tafsir` (max depth 1) |

Unknown query parameters return 422, never a silent ignore. Silently dropping a filter is how a client ships a bug that looks like a data problem for six months.

### 0.6 Rate limiting

Token bucket in Redis. Every response carries `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`, `X-RateLimit-Scope`.

| Bucket | Key | Limit | Burst |
| --- | --- | --- | --- |
| Content read | IP | 600/min | 100 |
| Authenticated read | user_id | 300/min | 60 |
| Write (general) | user_id | 120/min | 30 |
| Sync push | device_id | 20/min | 10 |
| Auth attempts | IP + email | 10/hour | 3 |
| AI messages | user_id | 20/hour free, 200/hour premium | 5 |
| Audio signing | user_id | 60/min | 20 |
| Analytics ingest | device_id | 30/min | 60 |

Two endpoints are exempt entirely: `GET /v1/prayer/methods` and `GET /v1/content/manifest`. Both are cached reference data, and throttling them could turn a cold start into a broken prayer configuration.

### 0.7 Idempotency

All creating or money-moving POSTs accept `Idempotency-Key`. Keys stored 24 hours. A replay returns the original response body and status plus `Idempotency-Replayed: true`. Required on `/v1/billing/*` and `/v1/sync/push`.

### 0.8 Caching

| Endpoint class | Header |
| --- | --- |
| Immutable content | `public, max-age=31536000, immutable` + ETag |
| Reference data | `public, max-age=86400, stale-while-revalidate=604800` |
| User data | `private, no-cache` + ETag |
| Entitlements | `private, max-age=300` |
| Everything mutable | `no-store` |

Conditional requests via `If-None-Match` supported on all GETs, returning 304.

---

## 1. Authentication

### POST /v1/auth/session

Exchanges a Firebase ID token for a session and provisions the user on first call.

Auth: `PUBLIC` - Rate limit: 30/min per IP

```json
{
  "firebase_id_token": "eyJhbGciOiJSUzI1NiIs...",
  "device": {
    "device_id": "018f3c2a-7b41-7c3e-9d21-a4b8c9e2f110",
    "platform": "android", "os_version": "14",
    "app_version": "1.4.2", "device_model": "Pixel 8"
  },
  "locale": "en", "timezone": "Europe/Paris"
}
```

```json
{
  "data": {
    "user": { "user_id": "018f3c2a-...", "is_anonymous": false,
              "email": "user@example.com" },
    "profiles": [ { "profile_id": "018f3c2b-...", "display_name": "Daoud",
                    "profile_type": "primary", "is_child_mode": false } ],
    "entitlement": { "tier": "free", "valid_until": null },
    "sync": { "current_revision": 8842 },
    "content": { "manifest_version": "2026.07.3" }
  }
}
```

Errors: 401 `token_invalid`, 401 `token_expired`, 403 `account_disabled`, 429.

One call returns everything a cold start needs. The alternative is five round trips before the app can render, which on a 2G connection is the difference between a usable app and an uninstall.

### Remaining auth endpoints

| Method | URL | Auth | Purpose | Notable errors |
| --- | --- | --- | --- | --- |
| POST | `/v1/auth/anonymous` | PUBLIC | Anonymous account, no PII | 429 |
| POST | `/v1/auth/link` | ANON | Upgrade anonymous to permanent, preserving all data | 409 `already_linked`, 409 `credential_in_use` |
| POST | `/v1/auth/refresh` | ANON | Rotate session | 401 `token_revoked` |
| DELETE | `/v1/auth/session` | ANON | Sign out this device | - |
| DELETE | `/v1/auth/sessions` | USER | Revoke all other devices | - |
| GET | `/v1/auth/devices` | USER | List active devices | - |
| DELETE | `/v1/auth/devices/{device_id}` | USER | Revoke one device | 404 |

`POST /v1/auth/link` is the most important endpoint in this module. Anonymous-first onboarding only works if upgrading never loses data. It runs as a single transaction re-parenting every profile to the permanent user, and returns 409 rather than merging if the target credential already has data - silent merges of two Hifz histories are unrecoverable.

---

## 2. Users and profiles

| Method | URL | Auth | Purpose |
| --- | --- | --- | --- |
| GET | `/v1/me` | ANON | User, profiles, entitlement |
| PATCH | `/v1/me` | USER | Locale, timezone, opt-ins |
| GET | `/v1/me/profiles` | USER | List |
| POST | `/v1/me/profiles` | USER | Create (max 6) |
| PATCH | `/v1/me/profiles/{id}` | USER | Update |
| DELETE | `/v1/me/profiles/{id}` | USER | Tombstone (not primary) |
| POST | `/v1/me/profiles/{id}/unlock` | USER | Verify parent PIN |
| POST | `/v1/me/export` | USER | Request full data export |
| GET | `/v1/me/export/{export_id}` | USER | Poll, get signed URL |
| POST | `/v1/me/deletion` | USER | Request deletion (30-day window) |
| DELETE | `/v1/me/deletion` | USER | Cancel pending deletion |

### POST /v1/me/export

Auth: `USER` - Rate limit: 3/day - Idempotency: required

```json
{
  "data": {
    "export_id": "018f3c2d-...", "status": "queued",
    "estimated_ready_at": "2026-07-31T22:10:00Z",
    "poll_url": "/v1/me/export/018f3c2d-..."
  }
}
```

Returns 202. Produces a signed URL valid 24 hours containing decrypted notes and AI conversations (re-encrypted under a user passphrase), the complete `review_attempt` log as NDJSON, and all engagement data. A Celery job, because a hafiz with five years of history has millions of attempt rows.

Errors: 409 `export_in_progress`, 429.

### POST /v1/me/deletion

Returns 202, not 200 - deletion is scheduled, not immediate, and the response says so with `purge_after`. The 30-day window is cancellable and stated in the response body rather than buried in a policy page.

---

## 3. Quran content

All content endpoints are PUBLIC, CDN-cached, immutable.

| Method | URL | Purpose |
| --- | --- | --- |
| GET | `/v1/quran/surahs` | All 114 with metadata |
| GET | `/v1/quran/surahs/{surah_id}` | One surah plus ayah range |
| GET | `/v1/quran/juz` | All 30 |
| GET | `/v1/quran/pages/{page_number}` | Mushaf page with line composition |
| GET | `/v1/quran/ayahs` | Filtered ayah list |
| GET | `/v1/quran/ayahs/{ayah_ref}` | Single ayah, accepts `2:255` or `262` |
| GET | `/v1/quran/ayahs/{ayah_ref}/words` | Word-by-word plus morphology |
| GET | `/v1/quran/search` | Full-text search |
| GET | `/v1/quran/translations` | Available editions |
| GET | `/v1/quran/translations/{slug}/text` | Verse range of one edition |
| GET | `/v1/quran/tafsir` | Available works |
| GET | `/v1/quran/tafsir/{slug}/text` | Commentary covering a verse |
| GET | `/v1/quran/roots/{root}` | Concordance by Arabic root |

### GET /v1/quran/pages/{page_number}

```http
GET /v1/quran/pages/255?mushaf=madani&expand=translation&translation=en-sahih-international
```

```json
{
  "data": {
    "mushaf": "madani", "page_number": 255, "juz_id": 13,
    "line_count": 15, "layout_hash": "sha256:9f2c...",
    "lines": [
      { "line_number": 1, "type": "ayah", "is_centered": false,
        "words": [ { "word_id": 33421, "ayah_id": 1780, "position": 1,
                     "text_uthmani": "...", "char_type": "word" } ] },
      { "line_number": 6, "type": "surah_header", "surah_id": 14 }
    ],
    "ayahs": [
      { "ayah_id": 1780, "surah_id": 13, "ayah_number": 42,
        "text_uthmani": "...", "sajdah_type": null,
        "translation": { "slug": "en-sahih-international", "body": "..." } }
    ]
  },
  "meta": { "content_version": "2026.07.3" }
}
```

`layout_hash` is compared by the client against its bundled asset hash. A mismatch means the cached page could render with different line breaks than the canonical mushaf, so the client discards its cache and re-fetches rather than showing a hafiz a page whose lines have shifted. This is the API-side half of the AR-1 mitigation.

### GET /v1/quran/search

Auth: PUBLIC - Rate limit: 120/min per IP - Pagination: cursor, 25/100

| Parameter | Values |
| --- | --- |
| `q` | Required, 2-100 chars |
| `mode` | `arabic` (diacritic-insensitive), `translation`, `transliteration`, `root` |
| `translation` | Edition slug, required when mode=translation |
| `surah`, `juz`, `page` | Scope filters, comma-separated |
| `sajdah` | Boolean |

```json
{
  "data": [
    { "ayah_id": 1, "surah_id": 1, "ayah_number": 1,
      "text_uthmani": "...", "highlights": [ { "start": 14, "end": 24 } ],
      "page_number": 1, "juz_id": 1, "score": 0.98 }
  ],
  "pagination": { "next_cursor": "...", "has_more": true, "limit": 25 },
  "meta": { "query_normalised": "...", "took_ms": 41 }
}
```

This endpoint exists for the web client and cross-translation search only. The mobile app searches locally against SQLite FTS5 and never calls it: search must work offline, and a round trip would make it feel slower than the 300ms target on a good connection, let alone a bad one.

Errors: 422 `query_too_short`, 422 `translation_required_for_mode`, 451.

### GET /v1/quran/translations

`availability` may be `available`, `region_restricted`, or `withdrawn`. A withdrawn edition returns metadata but 451 on its text - and clients that already downloaded it keep working offline. Licence expiry removes distribution rights, not the copy a user already has. That is the AR-4 mitigation and a deliberate legal position.

---

## 4. Bookmarks, highlights, notes

Sync-first resources. The REST endpoints exist for the web client and recovery; the mobile app writes locally and reconciles through `/v1/sync`.

| Method | URL | Auth | Purpose |
| --- | --- | --- | --- |
| GET | `/v1/bookmarks` | PROFILE | List, filter, paginate |
| POST | `/v1/bookmarks` | PROFILE | Create, idempotent by `bookmark_id` |
| PATCH | `/v1/bookmarks/{id}` | PROFILE | Update label/folder |
| DELETE | `/v1/bookmarks/{id}` | PROFILE | Tombstone |
| CRUD | `/v1/bookmark-folders[/{id}]` | PROFILE | Folders |
| CRUD | `/v1/highlights[/{id}]` | PROFILE | Highlights |
| CRUD | `/v1/notes[/{id}]` | PROFILE | Notes, ciphertext only |
| GET | `/v1/notes/conflicts` | PROFILE | Unresolved conflict copies |
| POST | `/v1/notes/{id}/resolve` | PROFILE | Keep one version, archive the other |

### POST /v1/bookmarks

```json
{
  "bookmark_id": "018f3c2e-7b41-7c3e-9d21-a4b8c9e2f110",
  "ayah_id": 262, "folder_id": null,
  "label": "Ayat al-Kursi",
  "client_updated_at": "2026-07-31T21:50:00Z"
}
```

```json
{
  "data": { "bookmark_id": "018f3c2e-...", "ayah_id": 262,
            "surah_id": 2, "ayah_number": 255,
            "label": "Ayat al-Kursi", "revision": 8843 }
}
```

The client generates the UUID, not the server. That is what makes offline creation and retry safe: re-sending the same `bookmark_id` returns 200 with the existing row instead of creating a duplicate. Combined with the partial unique index on `(profile_id, ayah_id) WHERE state='active'`, bookmarking the same verse from two offline devices converges to exactly one bookmark with no conflict UI.

Errors: 404 `ayah_not_found`, 404 `folder_not_found`, 403 `profile_mismatch`, 422.

### Notes: server-side constraint

`POST /v1/notes` accepts only ciphertext: `body_ciphertext`, `body_nonce`, `key_version`, `body_length`. There is no `body` field and no plaintext path. `GET /v1/notes?q=...` returns 422 `search_not_supported` directing the client to search locally. The API surface makes the privacy guarantee structural rather than a policy promise.

---

## 5. Audio

| Method | URL | Auth | Purpose |
| --- | --- | --- | --- |
| GET | `/v1/audio/reciters` | PUBLIC | Reciters and editions |
| GET | `/v1/audio/editions/{id}` | PUBLIC | Sizes, timing availability |
| GET | `/v1/audio/editions/{id}/segments` | PUBLIC | Verse timings for a range |
| POST | `/v1/audio/playback-url` | ANON | Signed streaming URL |
| POST | `/v1/audio/download-manifest` | ANON | Batch signed URLs for offline |
| GET | `/v1/audio/downloads` | PROFILE | What this device has, for storage UI |

### POST /v1/audio/playback-url

```json
{ "recitation_id": 7, "scope": "surah", "surah_id": 18,
  "codec": "opus", "bitrate_kbps": 64 }
```

```json
{
  "data": {
    "url": "https://cdn.quranone.app/audio/7/018.opus?Expires=...&Signature=...",
    "expires_at": "2026-07-31T23:00:00Z",
    "byte_size": 24817392, "duration_ms": 4382000,
    "sha256": "9f2c...", "supports_range": true
  }
}
```

Errors: 404 `recitation_not_found`, 409 `timings_unavailable`, 451, 429.

### POST /v1/audio/download-manifest

Returns up to 200 signed URLs in one call with a 6-hour expiry, because downloading a full reciter over a slow connection takes hours and re-signing mid-download would fail the whole job.

Every file carries its SHA-256 and the client verifies each chunk on write. A truncated recitation that silently plays half a surah is a worse failure than a download that visibly fails and retries.

---

## 6. Prayer times

**The API does not return prayer times for scheduling. This is the most important design decision in the specification.**

Prayer times are computed entirely on-device from a pure Dart astronomical engine. There is no endpoint the client calls to know when Maghrib is, and Athan notifications never depend on a network response.

1. **Correctness under failure.** A user in airplane mode, in a tunnel, on a dead network, or behind a captive portal must still be called to prayer. Any server dependency in that path is a defect.
2. **Privacy.** A prayer-times API is a location-tracking API wearing a different name. Serving times for a coordinate means logging that coordinate, five times a day, forever.
3. **Load.** Server-computed times convert worship into five globally synchronised request spikes per day. Competitors pay this cost daily; we do not have it.

What the API does serve is reference data and genuinely shared facts.

| Method | URL | Auth | Purpose |
| --- | --- | --- | --- |
| GET | `/v1/prayer/methods` | PUBLIC | Calculation methods (rate-limit exempt) |
| GET | `/v1/prayer/cities` | PUBLIC | City search for manual location |
| GET | `/v1/prayer/cities/nearest` | PUBLIC | Reverse-geocode to city plus method hint |
| GET | `/v1/prayer/config` | PROFILE | Synced prayer configuration |
| PUT | `/v1/prayer/config` | PROFILE | Update configuration |
| GET | `/v1/prayer/timetable` | PUBLIC | Monthly timetable, web/PDF export only |
| GET | `/v1/prayer/mosques` | PUBLIC | Nearby mosques |
| GET | `/v1/prayer/mosques/{id}/iqamah` | PUBLIC | Published iqamah times |
| GET/POST | `/v1/prayer/log` | PROFILE | Prayer log, opt-in, off by default |

### GET /v1/prayer/methods

```json
{
  "data": [
    { "method_id": 3, "slug": "mwl", "name": "Muslim World League",
      "fajr_angle": 18.0, "isha_angle": 17.0, "isha_interval_min": null,
      "midnight_mode": "standard", "region_hint": ["EU","US","CA"] },
    { "method_id": 4, "slug": "umm_al_qura", "name": "Umm al-Qura, Makkah",
      "fajr_angle": 18.5, "isha_angle": null, "isha_interval_min": 90,
      "region_hint": ["SA"] }
  ]
}
```

Bundled in the app binary as well as served, so a first launch with no network still configures prayer correctly.

### PUT /v1/prayer/config

Concurrency: `If-Match: "<revision>"`

```json
{
  "method_id": 3, "asr_juristic": "hanafi",
  "high_latitude_rule": "angle_based",
  "offsets": { "fajr": -2, "dhuhr": 0, "asr": 0, "maghrib": 3, "isha": 0 },
  "hijri_offset_days": 0,
  "location": { "latitude": 48.857, "longitude": 2.352, "city_id": 2988507 }
}
```

Coordinates are rounded to three decimals (~110 m) server-side regardless of what the client sends. Prayer calculation is insensitive to sub-kilometre precision, so there is no reason to hold a more precise location than the maths requires.

Errors: 409 `revision_stale`, 422 `invalid_offset`, 404 `method_not_found`.

### GET /v1/prayer/timetable

Serves the materialised monthly cache. Documented in the OpenAPI description as "for display and export only, not a scheduling source." The mobile client never calls it.

---

## 7. Qibla

| Method | URL | Auth | Purpose |
| --- | --- | --- | --- |
| GET | `/v1/qibla/declination` | PUBLIC | Magnetic declination for true-north correction |

One endpoint, and even it is optional. Qibla bearing is `atan2` against the Kaaba's fixed coordinates - a dozen lines of local maths. The only thing a device cannot compute is the magnetic declination model (WMM/IGRF), bundled as a coefficient table and refreshed roughly every five years.

```json
{
  "data": {
    "declination_degrees": 1.42, "model": "WMM-2025",
    "model_valid_until": "2030-01-01",
    "qibla_bearing_true": 119.16,
    "qibla_bearing_magnetic": 117.74,
    "distance_km": 4374.2
  }
}
```

`qibla_bearing_true` is returned as a cross-check, not as the value the client displays. The client computes its own bearing and compares; divergence beyond 0.1 degrees raises a diagnostic rather than silently trusting either side. Getting the Qibla wrong is a failure of a core religious duty, so it is worth having two independent computations agree.

---

## 8. Hadith

| Method | URL | Purpose |
| --- | --- | --- |
| GET | `/v1/hadith/collections` | Bukhari, Muslim, the Sunan |
| GET | `/v1/hadith/collections/{slug}/books` | Books within a collection |
| GET | `/v1/hadith/narrations` | Filtered, paginated |
| GET | `/v1/hadith/narrations/{id}` | Full narration, chain, grading |
| GET | `/v1/hadith/search` | Full-text search |
| GET | `/v1/hadith/topics` | Topical index |
| GET | `/v1/hadith/daily` | Deterministic hadith of the day |

```json
{
  "data": {
    "narration_id": 12345,
    "collection": { "slug": "bukhari", "name": "Sahih al-Bukhari" },
    "reference": { "collection_number": 8, "uri": "bukhari:8" },
    "text_arabic": "...",
    "translations": [ { "language_code": "en", "body": "..." } ],
    "grading": [
      { "authority": "al-Bukhari", "grade": "sahih", "note": null },
      { "authority": "al-Albani", "grade": "sahih", "note": null }
    ],
    "chain": { "narrators": [ { "name": "Abu Hurayrah", "death_year": 681 } ] },
    "related_ayahs": [ 262 ],
    "topics": ["belief","intention"]
  }
}
```

`grading` is an array of authorities, never a single scalar. Scholars disagree, and flattening that into one grade field would be the API quietly taking a position it has no standing to take.

Filters: `collection`, `grade` (sahih/hasan/daif/mawdu), `topic`, `book`, `related_ayah`.

---

## 9. Azkar and duas

| Method | URL | Auth | Purpose |
| --- | --- | --- | --- |
| GET | `/v1/azkar/categories` | PUBLIC | Morning, evening, sleep, travel |
| GET | `/v1/azkar/categories/{slug}` | PUBLIC | Duas in a category |
| GET | `/v1/azkar/duas/{id}` | PUBLIC | Text, transliteration, translation, source, audio |
| GET | `/v1/azkar/counters` | PROFILE | Dhikr counter state |
| POST | `/v1/azkar/counters/{dhikr_id}/increment` | PROFILE | CRDT increment |
| GET | `/v1/azkar/collections` | PROFILE | Custom collections |

```json
// Request
{ "delta": 33, "device_id": "018f3c2a-...", "occurred_at": "2026-07-31T21:55:00Z" }

// Response
{
  "data": {
    "dhikr_id": 4, "total": 132,
    "by_device": [ { "device_id": "018f3c2a-...", "count": 99 },
                   { "device_id": "018f3c31-...", "count": 33 } ],
    "target": 100, "revision": 8851
  }
}
```

The request sends a delta, never an absolute total. This is the API expression of the grow-only counter CRDT. An API accepting `{"count": 132}` would lose every concurrent count.

---

## 10. Ramadan

| Method | URL | Auth | Purpose |
| --- | --- | --- | --- |
| GET | `/v1/ramadan/calendar` | PUBLIC | Hijri calendar and Ramadan dates |
| GET | `/v1/ramadan/status` | PROFILE | Is it Ramadan, which day |
| GET/POST | `/v1/ramadan/fasting-log` | PROFILE | Fast tracking |
| GET/PUT | `/v1/ramadan/khatmah` | PROFILE | Completion plan |
| GET | `/v1/ramadan/taraweeh` | PROFILE | Nightly reading plan |
| GET | `/v1/ramadan/laylatul-qadr` | PUBLIC | Last-ten-nights guidance |

`POST /v1/ramadan/fasting-log` accepts `status` in (fasted, not_fasted, **exempt**, **travelling**, **ill**, make_up). Same doctrine as the prayer log: exemption is a first-class status, not a gap in the data. The API never requires a reason for `exempt` - there is no `reason` field, deliberately, because the app has no business asking.

```json
{
  "data": {
    "is_ramadan": false,
    "hijri_date": { "year": 1448, "month": 2, "day": 17, "month_name": "Safar" },
    "next_ramadan": { "estimated_start": "2027-02-08", "confidence": "estimated" },
    "days_until": 192
  }
}
```

`confidence` is `estimated` until local moon-sighting authorities confirm, then `confirmed`. The API never presents a calculated Hijri date as certain, because in much of the Muslim world it is not - and an app that confidently announces the wrong start of Ramadan loses trust it does not get back.

---

## 11. Learning and Hifz

| Method | URL | Auth | Purpose |
| --- | --- | --- | --- |
| GET | `/v1/hifz/units` | PROFILE | Units plus derived state |
| POST | `/v1/hifz/units` | PROFILE | Add verses to memorise |
| DELETE | `/v1/hifz/units/{id}` | PROFILE | Tombstone |
| GET | `/v1/hifz/due` | PROFILE | Today's review queue |
| POST | `/v1/hifz/attempts` | PROFILE | Batch append attempts |
| GET | `/v1/hifz/attempts` | PROFILE | Attempt history, paginated |
| POST | `/v1/hifz/recompute` | PROFILE | Force replay of derived state |
| CRUD | `/v1/hifz/plans[/{id}]` | PROFILE | Memorisation plans |
| GET | `/v1/hifz/stats` | PROFILE | Progress, retention, weak verses |
| GET/POST | `/v1/learning/lessons[/{id}/progress]` | PROFILE | Tajweed and Arabic |
| CRUD | `/v1/reading-plans[/{id}]` | PROFILE | Reading plans |
| GET | `/v1/achievements` | PROFILE | Definitions plus awards |

### POST /v1/hifz/attempts - the most carefully designed write in the API

Auth: PROFILE - Rate limit: 120/min - Idempotency: required

```json
{
  "attempts": [
    { "attempt_id": "018f3c32-7b41-7c3e-9d21-a4b8c9e2f110",
      "ayah_id": 262, "occurred_at": "2026-07-31T05:12:33Z",
      "session_id": "018f3c33-...", "stage_at_time": "sabqi",
      "grade": 4, "error_count": 1, "hesitation_ms": 820,
      "prompt_type": "recall", "duration_ms": 14200 }
  ],
  "device_id": "018f3c2a-..."
}
```

```json
{
  "data": {
    "accepted": 47, "duplicates_ignored": 3, "rejected": [],
    "derived": [
      { "ayah_id": 262, "mastery_score": 0.842, "stage": "sabqi",
        "next_review_at": "2026-08-04T05:00:00Z", "interval_days": 4.0,
        "derived_model_version": 3 }
    ],
    "revision": 8859
  }
}
```

- **Append-only.** There is no PATCH and no DELETE for attempts. The endpoints do not exist, matching the `REVOKE UPDATE, DELETE` at the database level.
- **Idempotent by `attempt_id`.** A retry after timeout gets `duplicates_ignored`, never a double-counted review.
- **Partial success is a success.** If 3 of 50 attempts fail validation the other 47 commit and the failures return in `rejected`. Rejecting the whole batch would mean one malformed row discards a user's entire morning session.
- **Derived state returns in the same response**, so the client needs no follow-up GET when the connection is one brief window in an otherwise offline day.

Errors: 422 `validation_failed`, 413 `batch_too_large` (>500), 403 `profile_mismatch`.

### POST /v1/hifz/recompute

Rate limit: 5/day. Replays the entire attempt log through the current scheduler and rewrites all derived fields. Returns 202 with a job handle.

This endpoint is the operational proof that the derived-cache design works. If mastery scores are ever wrong - a scheduler bug, a bad deploy, a sync anomaly - the fix is to call this, not to write a data-repair migration. The attempt log is always correct, so recovery is always available.

### GET /v1/hifz/stats

```json
{
  "data": {
    "total_ayahs_memorised": 1284, "juz_complete": 6,
    "retention_estimate": 0.87,
    "weak_ayahs": [ { "ayah_id": 1930, "mastery_score": 0.41 } ],
    "review_load_next_7_days": [22,18,31,25,19,27,24],
    "consistency_days_last_30": 27,
    "derived_at": "2026-07-31T21:55:00Z", "derived_model_version": 3
  }
}
```

No "days missed", no "broken streak", no negative framing anywhere in the payload. `consistency_days_last_30: 27` is a count of what happened, not a judgement about the other three. The API shape constrains what the UI can guilt someone with.

---

## 12. AI assistant

| Method | URL | Auth | Purpose |
| --- | --- | --- | --- |
| GET | `/v1/ai/conversations` | PROFILE | List, opt-in only |
| POST | `/v1/ai/conversations` | PROFILE | Start |
| GET | `/v1/ai/conversations/{id}/messages` | PROFILE | History |
| POST | `/v1/ai/conversations/{id}/messages` | PROFILE | Send, SSE streaming |
| DELETE | `/v1/ai/conversations/{id}` | PROFILE | Purge immediately |
| POST | `/v1/ai/messages/{id}/feedback` | PROFILE | Report a bad answer |
| GET | `/v1/ai/limits` | PROFILE | Remaining quota |

Rate limit: 20/hour free, 200/hour premium. Transport: `text/event-stream`.

```
event: token
data: {"delta":"Surah Al-Kahf was revealed"}

event: citation
data: {"ordinal":1,"source_type":"tafsir","tafsir_text_id":88213}

event: done
data: {"message_id":"018f3c35-...","citation_validated":true,"refusal_reason":null}
```

Refusal case:

```
event: done
data: {"refusal_reason":"fatwa_request",
       "body":"This is a question of religious ruling. I can share what classical
               sources say, but for a ruling on your situation please consult a
               qualified scholar."}
```

Three hard constraints, enforced server-side before a single token reaches the client:

1. **Every factual claim resolves to a real content row.** Citations are foreign keys into `content.ayah`, `content.hadith`, `content.tafsir_text`, validated before emission. A hallucinated hadith reference cannot be streamed because it cannot be resolved.
2. **`store: false` is the default.** Conversations persist only on explicit opt-in. DELETE purges immediately.
3. **Fatwa requests are refused, always.** Not hedged, not answered with a disclaimer. An AI issuing religious rulings is the fastest way for this product to cause real harm.

Errors: 429 `quota_exceeded`, 503 `ai_unavailable`, 413 `context_too_large`, 403 `ai_not_enabled_for_child_profile`.

---

## 13. Premium and billing

| Method | URL | Auth | Purpose |
| --- | --- | --- | --- |
| GET | `/v1/billing/plans` | ANON | Plans plus regional pricing |
| GET | `/v1/billing/entitlement` | ANON | Current tier |
| POST | `/v1/billing/verify-receipt` | USER | Validate a store purchase |
| GET | `/v1/billing/subscription` | USER | Current subscription |
| POST | `/v1/billing/subscription/cancel` | USER | Cancel |
| GET | `/v1/billing/payments` | USER | Payment history |
| POST | `/v1/billing/waqf/request` | USER | Request sponsored access |
| POST | `/v1/billing/waqf/sponsor` | USER | Sponsor others |
| POST | `/v1/webhooks/{provider}` | Signature | Store webhooks |

```json
{
  "data": {
    "tier": "premium", "source": "apple",
    "valid_until": "2027-03-01T00:00:00Z",
    "offline_grace_until": "2026-08-30T00:00:00Z",
    "features": ["unlimited_downloads","advanced_hifz","tafsir_full","ai_extended"],
    "grandfathered": []
  }
}
```

`offline_grace_until` is always 30 days ahead of the last successful check. A paying subscriber offline for three weeks does not lose access to features they paid for. Anything shorter punishes exactly the users in poor-connectivity markets whom the pricing model already strains.

`POST /v1/billing/verify-receipt` verifies server-to-store, never client-asserted. The raw payload is written to `billing.receipt_event` before parsing, so a parser bug is replayable rather than a lost purchase. Errors: 422 `receipt_invalid`, 409 `receipt_already_claimed`, 503 `store_unavailable`. A 409 never silently transfers a subscription between accounts - it opens a support path.

### The invariant that governs this module

No endpoint outside `/v1/billing/*` ever returns a 403 payment_required for a Quran, prayer, Qibla, or azkar resource. Asserted by a CI test that walks every route in the OpenAPI spec, calls it with entitlement stubbed to `none`, and fails the build on any payment-related rejection under `/v1/quran`, `/v1/prayer`, `/v1/qibla`, or `/v1/azkar`.

It is the machine-checked form of principle P4. A future engineer under revenue pressure cannot quietly gate a worship path, because the build will stop them.

---

## 14. Notifications

| Method | URL | Auth | Purpose |
| --- | --- | --- | --- |
| GET/PUT | `/v1/notifications/preferences` | PROFILE | Per-channel settings |
| POST | `/v1/notifications/token` | ANON | Register FCM/APNs token |
| DELETE | `/v1/notifications/token` | ANON | Deregister |
| POST | `/v1/notifications/diagnostic` | ANON | Submit self-diagnostic |
| POST | `/v1/notifications/test` | PROFILE | Trigger a real test push |
| GET | `/v1/notifications/delivery-log` | PROFILE | Recent deliveries, for support |
| GET | `/v1/notifications/inbox` | PROFILE | In-app announcements |

```json
// Request
{
  "device_id": "018f3c2a-...",
  "checks": {
    "notification_permission": "granted",
    "exact_alarm_permission": "denied",
    "battery_optimised": true,
    "dnd_active": false,
    "channel_enabled": true,
    "autostart_permitted": null
  },
  "oem": "xiaomi", "platform": "android", "os_version": "14"
}

// Response
{
  "data": {
    "verdict": "at_risk",
    "failing_checks": ["exact_alarm_permission","battery_optimised"],
    "remediation": [
      { "code": "miui_autostart", "severity": "critical",
        "title": "Allow autostart",
        "steps": ["Open Settings","Apps","Quran One","Autostart - enable"],
        "deep_link": "miui://settings/autostart" }
    ],
    "expected_reliability_pct": 62.4
  }
}
```

`expected_reliability_pct` is computed from real fleet data for that exact OEM, OS version and permission combination - not a guess. Telling a Xiaomi user "your Athan will fire about 62% of the time until you change this setting" is honest, specific, and actionable in a way a generic warning never is. The payload carries no `profile_id`.

**Push is never used for Athan, iqamah, or pre-prayer reminders.** Those are scheduled locally by the device from locally computed prayer times. Push carries only announcements, teacher assignments, and sync hints. A user offline for a week receives all 35 of their prayer notifications.

---

## 15. Analytics

| Method | URL | Auth | Purpose |
| --- | --- | --- | --- |
| POST | `/v1/analytics/events` | ANON | Batch ingest, opt-in |
| GET | `/v1/analytics/consent` | ANON | Current consent state |
| PUT | `/v1/analytics/consent` | ANON | Update consent |
| POST | `/v1/analytics/crash` | ANON | Crash report |

Rate limit 30/min per device, batches to 100 events. Returns 202.

```json
{ "data": { "accepted": 47, "dropped_no_consent": 0, "dropped_schema_invalid": 0 } }
```

- **202 and fire-and-forget.** Analytics never blocks a user action and never retries aggressively.
- **Server-side consent check.** Events without valid consent are dropped server-side. The client is not trusted to enforce the user's own privacy choice.
- **Schema allowlist.** Unknown properties are stripped, not stored. This prevents accidentally shipping an event that logs which verse someone bookmarked.
- **Never logged:** verse content, note text, AI messages, precise location, prayer log entries. Enforced by a CI test over the event schema registry.

`PUT /v1/analytics/consent` with `{"analytics": false}` takes effect immediately and triggers deletion of prior events for that device within 24 hours.

---

## 16. Sync

| Method | URL | Auth | Purpose |
| --- | --- | --- | --- |
| GET | `/v1/sync/pull` | PROFILE | Delta since revision |
| POST | `/v1/sync/push` | PROFILE | Batch upload local changes |
| GET | `/v1/sync/status` | PROFILE | Per-device cursor state |

```http
GET /v1/sync/pull?since_revision=8842&limit=200&entities=bookmark,highlight,note,hifz_unit
```

```json
{
  "data": {
    "changes": [
      { "entity_type": "bookmark", "entity_id": "018f3c2e-...",
        "operation": "I", "revision": 8843, "payload": {} }
    ],
    "current_revision": 8901, "has_more": true,
    "next_since_revision": 9042
  }
}
```

Revision-based, not cursor-based, because a sync cursor must survive a device being offline for months. An opaque keyset cursor can expire; a monotonic revision integer cannot.

`POST /v1/sync/push` returns per-item results with `applied`, `duplicate`, or `conflict`. Conflicts return both versions and the resolution applied:

```json
{
  "data": {
    "results": [
      { "entity_id": "018f3c2f-...", "status": "conflict",
        "resolution": "conflict_copy_created",
        "conflict_copy_id": "018f3c38-...", "server_revision": 8877 }
    ],
    "current_revision": 8902
  }
}
```

No push ever destroys data. Last-write-wins applies only to scalar preferences; notes create conflict copies, counters merge additively, attempt logs union. The API has no code path that discards a user's writing.

---

## 17. Three points for review

1. **The absence of a prayer-times endpoint will be challenged, repeatedly.** It looks like a missing feature to anyone reviewing the surface, and every competitor has one. It should be documented in the OpenAPI description itself so the reasoning travels with the spec.

2. **`POST /v1/hifz/attempts` needs batch-partial-success semantics before launch, not after.** Its real workload is a 50-item batch uploaded from a phone offline since Fajr. Rejecting all 50 because one row has a bad `hesitation_ms` will lose real memorisation history in the first week.

3. **The CI test that walks every route with entitlement stubbed to `none` is the highest-value test in the suite.** Three days of work, and the only thing standing between the product's core promise and a quarter where revenue is behind plan. It should be a launch blocker.
