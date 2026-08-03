# Quran One - Project Setup and Engineering Standards

Flutter stable - Material 3 - Android, iOS, Web - RTL and LTR - 12 UI languages
Depends on: TECHNICAL_ARCHITECTURE.md, FLUTTER_THEME_ARCHITECTURE.md, BLUEPRINT.md

---

## 0. What "scalable for millions of users" means for a Flutter client

The backend scales by adding machines. The client cannot. For an app of this shape the constraints that actually bind at scale are:

| Constraint | Why it binds |
| --- | --- |
| **Cold start under 2.0s** | Bounce rate on a worship app is unforgiving at Fajr |
| **Offline by default (P1)** | Millions of users on intermittent 3G in Indonesia, Pakistan, Nigeria |
| **Build time under 12 minutes** | 9 engineers x 6 PRs a day; a 40-minute CI kills throughput |
| **Under 80MB install** | Play Store install conversion falls off a cliff above 100MB |
| **Under 350MB peak RAM on 3GB devices** | Android kills background audio otherwise |
| **Modular boundaries** | The thing that stops a 9-person team from producing one 400-file feature folder |

Every decision below is downstream of one of those six.

---

## 1. Project setup

### 1.1 Toolchain, pinned

```
Flutter   3.29.x (stable channel)
Dart      3.7.x
Android   compileSdk 35, minSdk 24, targetSdk 35
iOS       deployment target 14.0
Web       CanvasKit renderer (not HTML - the mushaf needs it)
Xcode     16.x
JDK       17
```

Versions live in `.fvmrc` and `.tool-versions`. **CI fails if the local Flutter version does not match.** A team that runs different Flutter versions produces goldens that differ by a subpixel and nobody can tell whether a diff is real.

```bash
dart pub global activate fvm
fvm install 3.29.0 && fvm use 3.29.0
fvm flutter create --org app.quranone \
  --platforms=android,ios,web \
  --project-name quran_one .
```

### 1.2 Flavours

Three, on both platforms: `dev`, `staging`, `prod`.

| Flavour | Bundle id | API base | Analytics |
| --- | --- | --- | --- |
| dev | `app.quranone.dev` | `https://api-dev.quranone.app/v1` | Off |
| staging | `app.quranone.stg` | `https://api-stg.quranone.app/v1` | Debug view |
| prod | `app.quranone` | `https://api.quranone.app/v1` | On |

All three installable side by side. Configuration is compile-time via `--dart-define-from-file`, never a runtime `if (kDebugMode)`.

```bash
fvm flutter run --flavor dev --dart-define-from-file=config/dev.json
```

**Secrets are never in `--dart-define`.** They are readable from the binary. Anything sensitive is fetched at runtime from the backend after authentication.

### 1.3 Web specifics

- CanvasKit renderer, self-hosted (not the Google CDN - blocked in several target markets)
- Service worker configured for offline shell
- `flutter_bootstrap.js` customised with a theme-aware loading background including AMOLED black
- Font subsetting on; the Uthmanic Hafs face is loaded on demand, never in the initial bundle

Web is F-122, scheduled for M6, 14 dev-weeks. It is scaffolded from day one so that no platform-conditional code accumulates unchecked, but it does not gate mobile releases.

---

## 2. pubspec.yaml

```yaml
name: quran_one
description: Quran One - Quran, prayer and memorisation.
publish_to: none
version: 0.1.0+1

environment:
  sdk: ^3.7.0
  flutter: ^3.29.0

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # --- State, DI, routing -------------------------------------------------
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  go_router: ^14.6.2

  # --- Data / persistence -------------------------------------------------
  drift: ^2.23.0                 # SQLite + FTS5, typed, migration-tested
  sqlite3_flutter_libs: ^0.5.26
  drift_flutter: ^0.2.4
  shared_preferences: ^2.3.4
  flutter_secure_storage: ^9.2.3
  path_provider: ^2.1.5

  # --- Network ------------------------------------------------------------
  dio: ^5.7.0
  connectivity_plus: ^6.1.1
  retry: ^3.1.2

  # --- Models -------------------------------------------------------------
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # --- Audio --------------------------------------------------------------
  just_audio: ^0.9.42
  audio_service: ^0.18.16        # lock screen, CarPlay, Android Auto
  audio_session: ^0.1.22

  # --- Device -------------------------------------------------------------
  geolocator: ^13.0.2
  flutter_compass: ^0.8.1
  permission_handler: ^11.3.1
  device_info_plus: ^11.2.0
  package_info_plus: ^8.1.2
  wakelock_plus: ^1.2.10

  # --- Notifications / background ----------------------------------------
  flutter_local_notifications: ^18.0.1
  timezone: ^0.10.0              # required: athan across DST boundaries
  workmanager: ^0.5.2
  firebase_core: ^3.9.0
  firebase_messaging: ^15.1.6

  # --- Billing ------------------------------------------------------------
  in_app_purchase: ^3.2.0

  # --- UI -----------------------------------------------------------------
  dynamic_color: ^1.7.0
  flutter_svg: ^2.0.16
  vector_graphics: ^1.1.15
  material_symbols_icons: ^4.2801.0
  animations: ^2.0.11
  flutter_native_splash: ^2.4.4
  visibility_detector: ^0.4.0+2

  # --- Observability ------------------------------------------------------
  sentry_flutter: ^8.12.0
  firebase_analytics: ^11.3.7
  logger: ^2.5.0

  # --- Utility ------------------------------------------------------------
  collection: ^1.19.0
  intl: ^0.19.0
  equatable: ^2.0.7
  uuid: ^4.5.1
  crypto: ^3.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter

  build_runner: ^2.4.14
  riverpod_generator: ^2.6.3
  freezed: ^2.5.7
  json_serializable: ^6.9.0
  go_router_builder: ^2.7.1
  drift_dev: ^2.23.0

  very_good_analysis: ^6.0.0
  custom_lint: ^0.7.0
  riverpod_lint: ^2.6.3

  mocktail: ^1.0.4
  golden_toolkit: ^0.15.0
  patrol: ^3.13.0
  fake_async: ^1.3.2

flutter:
  uses-material-design: true
  generate: true                 # gen_l10n from lib/l10n/*.arb

  assets:
    - assets/icons/
    - assets/illustrations/
    - assets/data/

  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
    - family: IBMPlexSansArabic
      fonts:
        - asset: assets/fonts/IBMPlexSansArabic-Regular.ttf
          weight: 400
        - asset: assets/fonts/IBMPlexSansArabic-Medium.ttf
          weight: 500
        - asset: assets/fonts/IBMPlexSansArabic-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/IBMPlexSansArabic-Bold.ttf
          weight: 700
    - family: Literata
      fonts:
        - asset: assets/fonts/Literata-Regular.ttf
          weight: 400
        - asset: assets/fonts/Literata-SemiBold.ttf
          weight: 600
    - family: QuranOneIcons
      fonts:
        - asset: assets/fonts/QuranOneIcons.ttf

# NOT bundled - downloaded as content packs:
#   KFGQPCUthmanicHafs (~1.1 MB), NotoNaskhArabic (~340 KB),
#   translations, tafsir, recitation audio.
# Bundled font payload: ~580 KB.
```

### 2.1 Packages deliberately rejected

| Package | Why not |
| --- | --- |
| `get` | Service locator, routing and state in one global. Untestable at 9 engineers. |
| `provider` | Superseded by Riverpod; we are not running both. |
| `hive` | No FTS, no migrations, no relational queries. Search needs FTS5. |
| `lottie` / `rive` | Rejected in VISUAL_LANGUAGE.md. No figurative animation. |
| `google_fonts` | Runtime font download. Our fonts must work offline on first launch. |
| `flutter_bloc` | Fine framework; one state solution only, and Riverpod won on DI. |
| Any ad SDK | AR-8. A CI check fails the build if one appears transitively. |

**One state management solution. One routing solution. One DI solution.** The most expensive thing a large Flutter codebase can do is run two of anything.

---

## 3. Folder structure

Feature-first, Clean Architecture inside each feature.

```
lib/
  main_dev.dart  main_staging.dart  main_prod.dart
  app/
    app.dart                   # QuranOneApp
    bootstrap.dart             # runZonedGuarded, Sentry, DB warm-up
    router.dart

  core/
    theme/                     # see FLUTTER_THEME_ARCHITECTURE.md
    network/                   # Dio, interceptors, retry, RFC 9457 mapping
    database/                  # Drift schema, DAOs, migrations
    storage/                   # secure storage, prefs
    sync/                      # delta sync engine, conflict resolution
    error/                     # QFailure hierarchy, Result type
    logging/
    analytics/
    permissions/
    utils/

  design_system/               # see COMPONENT_LIBRARY.md
    theme/  primitives/  components/  domain/  feedback/

  ui/                          # see UI_KIT.md
    scaffolds/  templates/  states/

  features/
    quran/
      domain/
        entities/              # pure Dart. No Flutter, no JSON, no Drift.
        repositories/          # abstract interfaces
        usecases/
      data/
        models/                # freezed + json_serializable DTOs
        sources/               # local (Drift) and remote (Dio)
        repositories/          # implementations
      presentation/
        providers/
        screens/
        widgets/
    prayer/  qibla/  hadith/  azkar/  learning/
    audio/   auth/   premium/  settings/  search/  bookmarks/

  l10n/
    app_en.arb  app_ar.arb  app_fr.arb  app_id.arb  app_ur.arb
    app_tr.arb  app_ms.arb  app_bn.arb  app_es.arb  app_de.arb
    app_ru.arb  app_fa.arb

test/            unit + widget, mirroring lib/
test/golden/
integration_test/
tool/            codegen, asset pipeline, lint scripts
```

### 3.1 The dependency rule

```
presentation  ->  domain  <-  data
```

`domain` depends on nothing. Not Flutter, not Dio, not Drift. It is the layer that will still compile in five years.

Enforced mechanically:

```yaml
# analysis_options.yaml
custom_lint:
  rules:
    - forbidden_imports:
        - path: "lib/features/*/domain/**"
          forbidden: ["package:flutter/**", "package:dio/**", "package:drift/**"]
        - path: "lib/features/*/data/**"
          forbidden: ["lib/features/*/presentation/**"]
        - path: "lib/features/**"
          forbidden: ["lib/core/theme/color/**"]
```

### 3.2 Cross-feature communication

Features never import each other's `data` or `presentation`. Where feature A needs feature B, it depends on B's **domain interface**, resolved through Riverpod.

Example: the reader needs playback. It depends on `AudioPlaybackService` (an abstract class in `features/audio/domain`), not on `JustAudioPlayerImpl`. Which means the reader's tests run with a fake and no plugin channel.

---

## 4. Naming conventions

| Kind | Convention | Example |
| --- | --- | --- |
| Files | `snake_case.dart` | `ayah_repository_impl.dart` |
| Classes | `PascalCase` | `AyahRepositoryImpl` |
| Design system widgets | `Q` prefix | `QAyahCard` |
| Feature widgets | no prefix | `SurahListTile` |
| Domain entities | bare noun | `Ayah`, `PrayerTime` |
| Data DTOs | `Model` suffix | `AyahModel` |
| Repository interface / impl | `XRepository` / `XRepositoryImpl` | |
| Use cases | verb phrase | `GetAyahRange` |
| Riverpod providers | `camelCaseProvider` | `currentSurahProvider` |
| Notifiers | `XController` | `ThemeController` |
| Failures | `XFailure` | `NetworkFailure` |
| Booleans | `is` / `has` / `can` / `should` | `hasDownloadedAudio` |
| Async returning a future | verb | `fetchAyahs()` not `getAyahsFuture()` |
| Private | leading underscore | `_buildHeader()` |
| Constants | `lowerCamelCase` with `k` only for globals | `kArabicScale` |
| Test files | `<source>_test.dart` | `ayah_repository_impl_test.dart` |
| Goldens | `<component>_<theme>_<scale>_<dir>.png` | `ayah_card_amoled_2x_rtl.png` |
| Analytics events | `snake_case`, noun_verb | `ayah_bookmarked` |
| ARB keys | `camelCase`, screen-scoped | `readerPlayRecitation` |
| Branches | `type/short-description` | `feat/hifz-scheduler` |
| Commits | Conventional Commits | `feat(quran): add juz index` |

**One rule that matters more than the rest:** a file's name says what is in it, and a file contains one public thing. `utils.dart`, `helpers.dart` and `common.dart` are banned by lint. They are where code goes to become unfindable.

---

## 5. Coding standards

### 5.1 Analysis

```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    invalid_annotation_target: ignore
    missing_required_param: error
    missing_return: error
    todo: warning
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

linter:
  rules:
    prefer_const_constructors: true
    always_use_package_imports: true
    avoid_print: true
    require_trailing_commas: true
    unawaited_futures: true
    use_build_context_synchronously: true
```

### 5.2 The rules with teeth

| # | Rule | Rationale |
| --- | --- | --- |
| 1 | No `print` - `logger` only, structured | Grepping production logs |
| 2 | No `dynamic` outside JSON boundaries | `strict-casts` enforces |
| 3 | No `!` on a nullable except documented invariants | Null crashes at scale are the top crash class |
| 4 | Every `async` call site handles failure or documents why not | |
| 5 | No business logic in a widget | Review rejection |
| 6 | No `setState` in feature code | Riverpod is the only state mechanism |
| 7 | `const` everywhere the analyzer allows | Rebuild cost |
| 8 | No widget `build` over 60 lines - extract | Not a style rule; long builds rebuild too much |
| 9 | Extract to a `Widget` class, never a `_buildX()` method | A method is not a rebuild boundary |
| 10 | No `MediaQuery.of(context)` - use the specific `.sizeOf` / `.paddingOf` | Whole-`MediaQuery` dependency rebuilds on keyboard open |
| 11 | No `Duration(`, `Curves.`, `TextStyle(`, `Color(0x` outside their token files | Design system integrity |
| 12 | No `EdgeInsets.only(left:)` and friends - directional variants only | RTL |
| 13 | No `textScaler` clamping | ACCESSIBILITY.md, non-negotiable |
| 14 | Repository methods return `Result<T, QFailure>`, never throw | Exceptions as control flow do not survive 9 engineers |
| 15 | Every `ThemeExtension` implements `copyWith` and `lerp` | |
| 16 | Public API on `core/` and `design_system/` is dartdoc'd | |

### 5.3 Error handling

```dart
sealed class QFailure {
  const QFailure(this.message, {this.traceId});
  final String message;
  final String? traceId;
}

final class NetworkFailure extends QFailure { ... }
final class ServerFailure extends QFailure { ... }   // RFC 9457 problem detail
final class CacheFailure extends QFailure { ... }
final class PermissionFailure extends QFailure { ... }
final class ValidationFailure extends QFailure { ... }
final class SyncConflictFailure extends QFailure { ... }
```

A sealed hierarchy means an exhaustive `switch` at every presentation site, and the compiler tells us when a new failure type is unhandled. `traceId` is what the user copies from the error state - it is the difference between a support ticket that is solvable and one that is not.

### 5.4 Testing

| Layer | Target | Tooling |
| --- | --- | --- |
| Domain use cases | 100% | `test` |
| `domain/`, `sync/`, `billing/`, `learning/` branches | >90% | |
| Repositories | >85% | `mocktail` |
| Widgets | every design system component | `flutter_test` |
| Goldens | 2,416 comparisons per run | `golden_toolkit` |
| Integration | 5 critical journeys | `patrol` |
| Prayer times | 300 cases vs reference tables | `test` |
| Sync | 10,000 generated scenarios | property-based |
| Hifz scheduler | 1,000 synthetic learners x 180 days | simulation |

Every widget test carries the four accessibility assertions from ACCESSIBILITY.md section 12.

---

## 6. Best practices for scale

### 6.1 Performance

| Practice | Reason |
| --- | --- |
| `ref.watch(p.select((s) => s.field))` everywhere | Whole-object watch is the number one cause of jank in Riverpod apps |
| `ListView.builder` with `itemExtent` where fixed | Skips layout for off-screen children |
| `RepaintBoundary` on the mushaf page and the compass | Isolates the expensive paint |
| Slivers for anything with a header | Avoids nested scroll views |
| `cacheExtent` tuned to one screen, not the default 250 | Memory on 3GB devices |
| Images decoded at display size, never full resolution | |
| DevTools timeline on Pixel 4a and Galaxy A14 each sprint | Not on the developer's flagship |
| Text layout cached for the mushaf page | Shaping 604 pages of Arabic is the single hottest path |

Budgets, from the PRD: cold start <2.0s, 60fps across 604 pages with <1% dropped frames, search <300ms, memory <350MB, install <80MB, audio start <1.5s on 3G, battery <2%/hr.

### 6.2 Offline (P1)

Every read goes to the local database first. The network is an update mechanism, not a data source. Twelve of seventeen screens are byte-identical offline. Prayer times and Qibla are computed on device and **structurally cannot show a network error**.

### 6.3 CI/CD

```
PR:      format -> analyze -> custom_lint -> unit -> widget -> goldens
         (target: under 12 minutes)
Main:    + integration (Patrol, 3 devices) + build all flavours
Release: + signed artefacts + Sentry symbols + staged rollout 5/25/50/100
```

Blocking gates: analyzer clean, coverage thresholds, golden diffs zero, no new `TODO` without an issue link, **no ad SDK in the transitive dependency tree (AR-8)**, licence audit, premium-unreachable route-graph test.

### 6.4 Localisation

12 UI languages, `gen_l10n`, ARB. No string literal in a widget - lint enforced. Every ARB entry carries a `@description` with context for translators. Plurals and gender via ICU. **The copy doctrine from BLUEPRINT.md is linted across all 12 locales**: no guilt language, no streak-shaming, no fire emoji.

### 6.5 Release engineering

Trunk-based. Short-lived branches, squash merge. Release branches cut from main, cherry-picks only. Feature flags for anything crossing a release boundary. Semantic versioning; build number is the CI run number. Staged rollout with automated halt on a crash-free-sessions regression.

---

## 7. Four positions worth arguing about

**1. Feature-first with a full Clean Architecture triad inside each feature is a lot of ceremony for a small feature.** Qibla will have three files in `domain/` that feel like paperwork. The consistency is what pays: nine engineers should never have to ask where something lives, and the boundary is what makes the reader testable without an audio plugin.

**2. Drift over a lighter store is a real cost.** Codegen, migration tests, a build_runner step in everyone's loop. It is justified by exactly one requirement - FTS5 search under 300ms across 6,236 ayahs plus translations plus hadith - and by migrations being tested rather than hoped for. If search were not a first-class feature this would be over-engineering.

**3. Banning `_buildX()` methods will annoy people who have written Flutter for years.** It is not a style preference. A method returning a widget is not a rebuild boundary; a `StatelessWidget` class is. On the mushaf page that distinction is measurable in dropped frames.

**4. Three flavours x three platforms is nine build configurations to keep alive, and web will be the one that rots.** It is scaffolded from day one but not shipped until M6, which means eleven months of web builds that nobody actually runs. The mitigation is compiling web on every main build; the honest risk is that compiling is not the same as working, and we will discover the gap in M6 rather than now.
