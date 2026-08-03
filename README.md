# Quran One

Quran, prayer times, qibla and memorisation. Flutter for Android, iOS and web,
with a Django REST backend.

Everything that matters works offline. The network is an update mechanism,
never a read path.

---

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --target lib/main_dev.dart --dart-define-from-file=config/dev.json
```

The second step is not optional. Riverpod providers, Drift tables and Freezed
models are all generated; `.g.dart` files are gitignored on purpose so that
generated code never appears in a diff.

### Requirements

| Tool | Version |
| --- | --- |
| Flutter | 3.29.x stable |
| Dart | 3.7.x |
| JDK | 17 |
| Xcode | 16.x |
| Android | compileSdk 35, minSdk 24 |
| iOS | 14.0 |

### Flavours

| Flavour | Entry point | Config |
| --- | --- | --- |
| dev | `lib/main_dev.dart` | `config/dev.json` |
| staging | `lib/main_staging.dart` | `config/staging.json` |
| prod | `lib/main_prod.dart` | `config/prod.json` |

---

## Project structure

```
lib/
  app/          composition root, bootstrap, router, startup tasks
  core/         framework-level infrastructure, no domain knowledge
  shared/       cross-feature UI and service contracts
  features/     feature-first modules, each with domain/data/presentation
  presentation/ app-level presentation state (theme, locale)
  l10n/         translations
```

### The one rule

`domain/` depends on nothing. No Flutter, no Riverpod, no Drift, no Dio. If a
domain folder cannot compile as plain Dart, the business rules are entangled
with the framework and can no longer be tested cheaply. This is enforced by
`test/architecture/layering_test.dart`, not by good intentions.

### Dependency injection

Riverpod is the only container. `app/di.dart` is the only file where an
interface meets its implementation. Providers return interfaces, never `*Impl`
types - there is a test for that too.

Exactly three providers are overridden at the root, in `bootstrap.dart`:
preferences, database and config. Three blocking startup tasks resolve them
before the first frame, which is why no screen in the app renders a loading
state for the database.

---

## What is here so far

| Area | State |
| --- | --- |
| Bootstrap, startup tasks, flavours | Implemented |
| Theme system: light, dark, AMOLED | Implemented, contrast-tested |
| Typography, Arabic and Latin pairing | Implemented |
| Router, four-destination shell | Implemented |
| Quran domain, data, reader | Implemented against the seed index |
| Prayer, qibla, hadith, azkar, learning | Screens stubbed |
| Content pack pipeline | Not started |
| Backend | Not started |

The Uthmani text is deliberately absent. Scripture ships as a signed,
versioned content pack, not as a bundled asset, so that a correction can ship
without an app release and so that nothing unverified ever renders.

---

## Testing

```bash
flutter test
```

Five layers, cheapest first:

1. Pure Dart - entities, value objects, prayer calculation, SRS scheduling.
   No container, no widgets, no mocks.
2. Use cases with hand-written fakes. Constructor injection means these need
   no Riverpod at all.
3. `ProviderContainer` with overrides, via `test/helpers/container.dart`.
4. Widget and golden tests.
5. Patrol journeys on real devices.

Fakes are preferred over mocks. A fake survives an interface change as a
compile error; a mock survives it as a runtime null.

---

## Documentation

Design and engineering documents live in [`docs/`](docs). Start with
[`docs/BLUEPRINT.md`](docs/BLUEPRINT.md), then
[`docs/CLEAN_ARCHITECTURE.md`](docs/CLEAN_ARCHITECTURE.md) and
[`docs/DEPENDENCY_INJECTION.md`](docs/DEPENDENCY_INJECTION.md).

---

## Principles

1. Offline is the default, not a degraded mode.
2. Sacred content is immutable and verified.
3. Religious data is private by default.
4. Worship paths never carry commerce.
5. Content changes without an app release.
