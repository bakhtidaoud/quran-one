# Quran One

Quran, prayer times, qibla and memorisation.

- **App** - Flutter, for Android, iOS and web.
- **API** - Django 5.1 + DRF, PostgreSQL, Redis, Celery.

Everything that matters works offline. The network is an update mechanism,
never a read path.

```
.
  lib/          Flutter application
  test/         Flutter tests
  assets/       bundled seed data
  backend/      Django REST API
  docs/         product, design and engineering documents
```

---

## Run the app

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --target lib/main_dev.dart --dart-define-from-file=config/dev.json
```

The second step is not optional. Riverpod providers, Drift tables and route
definitions are generated; `.g.dart` files are gitignored so that generated
code never appears in a diff.

Platform folders are not committed. Run `flutter create . --org app.quranone
--platforms=android,ios,web` once after cloning; it fills in the missing
Gradle, Xcode and web scaffolding and leaves `lib/` alone.

| Tool | Version |
| --- | --- |
| Flutter | 3.29.x stable |
| Dart | 3.7.x |
| JDK | 17 |
| Android | compileSdk 35, minSdk 24 |
| iOS | 14.0 |

| Flavour | Entry point | Config |
| --- | --- | --- |
| dev | `lib/main_dev.dart` | `config/dev.json` |
| staging | `lib/main_staging.dart` | `config/staging.json` |
| prod | `lib/main_prod.dart` | `config/prod.json` |

## Run the API

```bash
cd backend
cp .env.example .env
docker compose up --build
docker compose exec api python manage.py migrate
```

API at `http://localhost:8000/v1/`, OpenAPI docs at `/docs/`. Details in
[`backend/README.md`](backend/README.md).

---

## Architecture

### App

```
lib/
  app/          composition root, bootstrap, router, startup tasks
  core/         framework-level infrastructure, no domain knowledge
  shared/       cross-feature UI and service contracts
  features/     feature-first modules, each with domain/data/presentation
  presentation/ app-level presentation state (theme, locale)
  l10n/         translations
```

`domain/` depends on nothing. No Flutter, no Riverpod, no Drift, no Dio. If a
domain folder cannot compile as plain Dart, the business rules are entangled
with the framework and can no longer be tested cheaply. Enforced by
`test/architecture/layering_test.dart`, not by good intentions.

Riverpod is the only container, and `lib/app/di.dart` is the only file where an
interface meets its implementation. Providers return interfaces, never `*Impl`
types; there is a test for that too.

### API

```
backend/
  config/       settings split by environment, urls, celery
  apps/core/    abstract models, error envelope, pagination, logging
  apps/accounts/  user, profile, JWT auth
  apps/quran/     surahs, ayat, translations, reciters, bookmarks
  apps/content/   content pack catalogue and signed downloads
  apps/prayer/    calculation methods, regional defaults, mosques
  apps/sync/      devices, hifz cards, positions, conflict resolution
  apps/billing/   subscriptions, entitlement, store webhooks
```

The API returns one error envelope for every failure. The Flutter client maps
`error.code` onto its sealed `QFailure` hierarchy, which is why adding a code
is treated as a breaking change.

---

## Where the two halves disagree, on purpose

**Prayer times have no endpoint.** They are computed on device. A prayer time
that needs a network call fails on a plane, in a basement, and in the places
with the most users and the worst connectivity.

**Scripture is immutable server-side and absent client-side.** Surah and Ayah
rows raise on update, including from the Django admin. The Uthmani text is not
bundled in the app either - it arrives as a signed, checksummed content pack,
so a correction ships without an app release and nothing unverified renders.

**The client is authoritative, except for money.** Worship data syncs on the
client's terms. Entitlement is the one thing derived server-side from a
validated store receipt.

**Nothing is hard-deleted.** Tombstones sync; absent rows do not.

---

## Current state

| Area | State |
| --- | --- |
| App bootstrap, flavours, startup tasks | Implemented |
| Theme system: light, dark, AMOLED | Implemented, contrast-tested |
| Router, four-destination shell | Implemented |
| Quran domain, data, reader | Implemented against the seed index |
| Prayer, qibla, hadith, azkar, learning screens | Stubbed |
| API: auth, quran, content, prayer, sync, billing | Implemented |
| Migrations | Not generated yet |
| Content pack build pipeline | Not started |

## Tests

```bash
flutter test
cd backend && pytest
```

Fakes are preferred over mocks on both sides. A fake survives an interface
change as a compile error; a mock survives it as a runtime null.

## Documentation

[`docs/`](docs) holds the product and engineering documents. Start with
[`docs/BLUEPRINT.md`](docs/BLUEPRINT.md), then
[`docs/CLEAN_ARCHITECTURE.md`](docs/CLEAN_ARCHITECTURE.md),
[`docs/DATABASE_DESIGN.md`](docs/DATABASE_DESIGN.md) and
[`docs/API_SPECIFICATION.md`](docs/API_SPECIFICATION.md).
