# Quran One - Architecture Feature Matrix

## 0. Estimation basis and legend

| Parameter | Assumption |
| --- | --- |
| Team | 9 engineers: 3 Flutter, 2 Django, 1 platform/DevOps, 1 data/content, 1 QA automation, 1 mobile-platform specialist (notifications and audio) |
| Unit | **dev-weeks** = 1 engineer x 1 week, including tests, review and QA fixes |
| Excluded | Content licensing negotiation, scholarly review cycles, translation copy-editing, design exploration |
| Included | Offline behaviour, sync, accessibility baseline, platform-specific hardening |

| Legend | Values |
| --- | --- |
| MoSCoW | Must / Should / Could / Future |
| Priority | P0 launch gate, P1 launch target, P2 post-launch, P3 exploratory |
| Complexity | S up to 3 wks well-understood; M 4 to 8 wks; L 9 to 14 wks; XL 15 wks or more, or high unknowns |
| Business value | H drives acquisition, retention or trust; M meaningful but substitutable; L narrow segment or polish |

---

## 1. MUST HAVE

### 1.1 Platform foundation

| ID | Feature | Pri | Cx | Dependencies | Est | Value |
| --- | --- | --- | --- | --- | --- | --- |
| F-001 | Flutter app shell, navigation, DI, theming skeleton | P0 | M | - | 4 | H |
| F-002 | Django REST API skeleton, /api/v1/, auth middleware | P0 | M | - | 5 | H |
| F-003 | PostgreSQL schema and migrations (content and user domains separated) | P0 | M | F-002 | 4 | H |
| F-004 | Redis caching, rate limiting, Celery queue wiring | P0 | S | F-002 | 2 | M |
| F-005 | Local persistence layer (SQLite/Drift) and client migration framework | P0 | M | F-001 | 5 | H |
| F-006 | **Offline-first sync engine**: delta sync, LWW for scalars, CRDT counters | P0 | L | F-003, F-005 | 12 | H |
| F-007 | Versioned content packs, CDN delivery, integrity checksums | P0 | M | F-003 | 6 | H |
| F-008 | Firebase Auth (Apple, Google, email/password) | P0 | S | F-002 | 3 | H |
| F-009 | Push infrastructure (FCM and APNs), token lifecycle, silent refresh | P0 | S | F-002 | 3 | H |
| F-010 | CI/CD, **golden-file mushaf test harness**, OEM device farm matrix | P0 | M | F-001 | 6 | H |
| F-011 | Observability: crash, performance, privacy-safe analytics with opt-out | P0 | M | F-001, F-002 | 4 | M |
| F-012 | Feature flags and remote config | P0 | S | F-001 | 2 | M |
| | **Subtotal** | | | | **56** | |

### 1.2 Quran core

| ID | Feature | Pri | Cx | Dependencies | Est | Value |
| --- | --- | --- | --- | --- | --- | --- |
| F-020 | Canonical Uthmani text ingestion, launch-time checksum verification | P0 | M | F-003, F-007 | 4 | H |
| F-021 | **604-page Madani mushaf renderer, page-faithful** | P0 | L | F-020, F-001 | 14 | H |
| F-022 | Verse-list reading mode | P0 | S | F-020, F-024 | 4 | H |
| F-023 | Navigation: surah, juz, hizb, page, ruku, jump-to-verse | P0 | S | F-020 | 3 | H |
| F-024 | Translation framework and ingestion of 25 translations | P0 | M | F-003, F-007 | 8 | H |
| F-025 | Transliteration, single documented scheme | P0 | S | F-020 | 3 | M |
| F-026 | Offline FTS search, diacritic-insensitive, Arabic and translations and notes | P0 | M | F-005, F-020, F-024 | 7 | H |
| F-027 | Bookmarks, notes, highlights with sync | P0 | M | F-006 | 5 | H |
| F-028 | Reading position persistence across force-quit and devices | P0 | S | F-005, F-006 | 2 | H |
| F-029 | Typography and theming engine: 3 or more Arabic fonts, sizes, 4 themes | P0 | M | F-021 | 5 | H |
| F-030 | Share as image, copy with reference and attribution | P0 | S | F-020, F-024 | 4 | M |
| F-031 | Sajdah, waqf and juz marker rendering | P0 | S | F-021 | 2 | M |
| | **Subtotal** | | | | **61** | |

### 1.3 Audio

| ID | Feature | Pri | Cx | Dependencies | Est | Value |
| --- | --- | --- | --- | --- | --- | --- |
| F-040 | Audio engine: **gapless**, background, lock-screen and route controls | P0 | M | F-001 | 9 | H |
| F-041 | Verse-synced highlighting from timing data | P0 | M | F-040, F-021 | 7 | H |
| F-042 | Reciter catalogue and ingestion of 5 launch reciters | P0 | M | F-007 | 5 | H |
| F-043 | Download manager: scoped, resumable, Wi-Fi-only default | P0 | M | F-007, F-042 | 7 | H |
| F-044 | Repeat and loop ranges, A-B repeat, 0.5x to 2.0x with pitch preservation | P0 | S | F-040 | 4 | H |
| F-045 | Storage manager with pre-download space check | P0 | S | F-043 | 3 | M |
| | **Subtotal** | | | | **35** | |

### 1.4 Prayer and Qibla

| ID | Feature | Pri | Cx | Dependencies | Est | Value |
| --- | --- | --- | --- | --- | --- | --- |
| F-050 | On-device prayer time engine: 13 methods, Asr juristic, high-latitude, offsets | P0 | M | F-005 | 8 | H |
| F-051 | Location and time-zone handling: auto-detect, manual city, offline city DB | P0 | M | F-050 | 5 | H |
| F-052 | **Athan scheduler and OEM reliability hardening** (Xiaomi, Huawei, Oppo, Samsung, iOS) | P0 | L | F-050, F-009 | 12 | H |
| F-053 | 5 muadhin voices, per-prayer audible/vibrate/silent modes | P0 | S | F-052, F-043 | 4 | H |
| F-054 | Pre-prayer reminders, 5 to 60 min, per-prayer | P0 | S | F-052 | 2 | M |
| F-055 | **Athan self-diagnostic**: detects OS suppression, battery optimisation, DND | P0 | S | F-052 | 4 | H |
| F-056 | Qibla: magnetometer compass, calibration guidance, map fallback | P0 | M | F-051 | 6 | H |
| F-057 | Hijri calendar with plus or minus 2 day offset | P0 | S | F-050 | 3 | M |
| | **Subtotal** | | | | **44** | |

### 1.5 Duas and Azkar

| ID | Feature | Pri | Cx | Dependencies | Est | Value |
| --- | --- | --- | --- | --- | --- | --- |
| F-060 | Dua library (Hisnul Muslim base), every entry sourced | P0 | S | F-007 | 4 | H |
| F-061 | Morning and evening adhkar guided counter, interrupt-safe | P0 | S | F-060, F-005 | 3 | M |
| F-062 | Dua audio with speed control | P0 | S | F-040, F-060 | 3 | M |
| | **Subtotal** | | | | **10** | |

### 1.6 Account, monetisation, settings, accessibility

| ID | Feature | Pri | Cx | Dependencies | Est | Value |
| --- | --- | --- | --- | --- | --- | --- |
| F-070 | Anonymous-first usage and idempotent local-to-account data migration | P0 | M | F-006, F-008 | 5 | H |
| F-071 | Account management: device list and revoke, self-service delete, data export | P0 | M | F-008 | 5 | H |
| F-072 | Entitlement service and receipt validation (StoreKit, Play Billing, Stripe web) | P0 | M | F-002, F-008 | 9 | H |
| F-073 | Regional PPP pricing ladder, three tiers | P0 | S | F-072 | 3 | H |
| F-074 | Paywall and value screen, free-tier guarantee disclosure | P0 | S | F-072 | 4 | H |
| F-075 | **Premium invariant test suite**: ad-SDK check, paywall-over-scripture assertion, copy doctrine lint | P0 | S | F-010, F-074 | 3 | H |
| F-076 | Settings surface for all P0 toggles, plain-language explanations | P0 | M | F-050, F-052 | 5 | H |
| F-077 | Localisation framework, 12 languages, full RTL (Arabic, Urdu, Farsi) | P0 | M | F-001 | 8 | H |
| F-078 | Accessibility baseline: screen reader, 200 percent text scale, contrast, reduced motion | P0 | M | F-021, F-029 | 6 | H |
| F-079 | Privacy summary, analytics opt-out, published SDK disclosure | P0 | S | F-011 | 3 | H |
| | **Subtotal** | | | | **51** | |

> **MUST HAVE TOTAL: 257 dev-weeks**, roughly 29 calendar weeks at 9 engineers assuming 80 percent allocation.

---

## 2. SHOULD HAVE

| ID | Feature | Pri | Cx | Dependencies | Est | Value |
| --- | --- | --- | --- | --- | --- | --- |
| F-100 | **Hifz spaced-repetition engine**: scheduler, decay model, fully offline | P1 | L | F-005, F-006 | 14 | H |
| F-101 | Hifz session UI: sabaq, sabqi, manzil queues | P1 | M | F-100, F-021 | 8 | H |
| F-102 | Per-verse mastery model and weakness report | P1 | M | F-100 | 6 | H |
| F-103 | Hifz progress dashboard and PDF export for teachers | P1 | M | F-102 | 5 | M |
| F-104 | Recitation record and compare, on-device only | P1 | M | F-040 | 6 | H |
| F-105 | Word-by-word translation and morphology database | P1 | M | F-020, F-007 | 9 | H |
| F-106 | Root and lemma concordance with occurrence navigation | P1 | M | F-105 | 5 | M |
| F-107 | Tafsir framework and 4 works, edition and abridgement disclosed | P1 | M | F-024, F-007 | 8 | H |
| F-108 | Tajweed colour-coding with legend | P1 | M | F-021 | 7 | H |
| F-109 | Multi-translation side by side, up to 3 | P1 | S | F-024 | 4 | M |
| F-110 | Reading plans engine with missed-day redistribution | P1 | M | F-028, F-006 | 6 | H |
| F-111 | Hadith module: 6 collections, grading metadata, offline search | P1 | L | F-007, F-026 | 12 | M |
| F-112 | Prayer logging, qada list, **privacy-first pause** with no streak break | P1 | M | F-050, F-006 | 5 | H |
| F-113 | Home-screen widgets, iOS and Android, 3 sizes, free tier | P1 | M | F-050 | 6 | H |
| F-114 | Apple Watch complication and Wear OS tile | P1 | M | F-050, F-113 | 8 | M |
| F-115 | Monthly timetable and PDF export | P1 | S | F-050 | 3 | M |
| F-116 | Ramadan module: countdowns, seasonal layout, calendar, fast tracking, taraweeh | P1 | L | F-050, F-057, F-110 | 10 | H |
| F-117 | Learning path and **step-by-step salah instruction** | P1 | L | F-040, F-007 | 10 | H |
| F-118 | Arabic alphabet and letter-joining lessons | P1 | M | F-117 | 8 | H |
| F-119 | Vocabulary SRS reusing the F-100 engine | P1 | S | F-100, F-105 | 4 | M |
| F-120 | Personal dashboard: reading, listening, prayer, dhikr statistics | P1 | M | F-006 | 7 | M |
| F-121 | **Streak integrity service**: versioned, server-backed, 30-day restorable | P1 | S | F-006, F-120 | 4 | H |
| F-122 | Responsive web app (Flutter web), reader and prayer parity | P1 | L | F-021, F-050 | 14 | H |
| F-123 | Waqf sponsored-access pool and gifting flow | P1 | M | F-072 | 5 | H |
| F-124 | Family plan and child profiles under one account | P1 | M | F-072, F-070 | 6 | M |
| F-125 | Biometric app lock | P1 | S | F-008 | 2 | M |
| F-126 | Tablet two-page spread with correct RTL ordering | P1 | S | F-021 | 4 | M |
| F-127 | Custom dua collections, favourites, digital tasbih with haptics | P1 | S | F-060 | 4 | M |
| F-128 | Full data export and import (JSON) | P1 | S | F-071 | 3 | M |
| F-129 | Iqamah reminders per prayer | P1 | S | F-052 | 2 | M |
| F-130 | Content error reporting and **hot content updates without app release** | P1 | S | F-007 | 4 | H |
| | **SHOULD HAVE TOTAL** | | | | **199** | |

---

## 3. COULD HAVE

| ID | Feature | Pri | Cx | Dependencies | Est | Value |
| --- | --- | --- | --- | --- | --- | --- |
| F-200 | Teacher and roster dashboard, verse-range assignments | P2 | L | F-102, F-124 | 10 | M |
| F-201 | Institution licensing, admin console, invoice billing | P2 | M | F-072, F-200 | 8 | M |
| F-202 | Verified mosque accounts publishing iqamah times | P2 | M | F-050, F-002 | 8 | M |
| F-203 | Nearby mosque finder, no sponsored placements | P2 | M | F-051 | 5 | L |
| F-204 | Kids mode: simplified home, audio-first lessons, simple Qibla | P2 | L | F-124, F-117 | 12 | M |
| F-205 | Parental controls and age-banded weekly child summaries | P2 | M | F-204, F-120 | 6 | M |
| F-206 | Curated thematic index and topic browse | P2 | M | F-020, F-024 | 5 | M |
| F-207 | Hadith audio | P2 | S | F-111, F-040 | 4 | L |
| F-208 | Contextual dua categories (travel, illness, exams, distress) | P2 | S | F-060 | 3 | M |
| F-209 | AR camera Qibla overlay, never default | P2 | M | F-056 | 5 | L |
| F-210 | Spoken Qibla guidance for visually impaired users | P2 | S | F-056, F-078 | 3 | M |
| F-211 | Yearly in review, generated locally, opt-in | P2 | S | F-120 | 3 | L |
| F-212 | Notes export as Markdown with references preserved | P2 | S | F-128 | 2 | M |
| F-213 | Self-timed reading speed measurement and trend | P2 | S | F-120 | 3 | L |
| F-214 | Itikaf mode and Laylatul Qadr reminders | P2 | S | F-116 | 3 | M |
| F-215 | Voluntary fasting reminders (Mon, Thu, Ayyam al-Bid) | P2 | S | F-057 | 2 | M |
| F-216 | Eid prayer time estimate and takbir | P2 | S | F-057 | 2 | L |
| F-217 | Shareable curated hadith collections | P2 | S | F-111 | 4 | L |
| F-218 | Support-assisted account merge tooling | P2 | S | F-070 | 4 | L |
| F-219 | High-contrast mode and dyslexia-friendly translation font | P2 | S | F-078 | 2 | M |
| | **COULD HAVE TOTAL** | | | | **94** | |

---

## 4. FUTURE

| ID | Feature | Pri | Cx | Dependencies | Est | Value |
| --- | --- | --- | --- | --- | --- | --- |
| F-300 | AI assistant: grounded retrieval and **citation validation against content DB** | P3 | XL | F-026, F-107, F-111 | 16 | M |
| F-301 | AI guardrail layer: no-fatwa classifier, refusal policy, AI disclosure | P3 | L | F-300 | 10 | H |
| F-302 | AI semantic verse search from vague description | P3 | M | F-300 | 8 | M |
| F-303 | Scholar review-board tooling and response audit sampling | P3 | M | F-300, F-301 | 6 | H |
| F-304 | **On-device recitation error detection** (ASR and tajweed scoring) | P3 | XL | F-104 | 24 | H |
| F-305 | Live tajweed feedback tuned for children | P3 | L | F-304, F-204 | 12 | M |
| F-306 | Community study circles and shared Khatmah | P3 | L | F-110, F-124 | 14 | M |
| F-307 | Desktop apps (macOS, Windows) | P3 | L | F-122 | 12 | L |
| F-308 | CarPlay and Android Auto audio | P3 | M | F-040 | 8 | M |
| F-309 | Machine-assisted tafsir translation pipeline with scholar review | P3 | L | F-107 | 10 | M |
| F-310 | Content expansion: 25 more translations, 20 more reciters | P3 | L | F-024, F-042 | 10 | M |
| F-311 | Advanced accessibility: Braille display, tactile navigation | P3 | M | F-078 | 8 | M |
| F-312 | Public API and developer platform | P3 | L | F-002 | 12 | L |
| F-313 | TV app for family Ramadan recitation | P3 | M | F-040 | 8 | L |
| F-314 | Public Waqf transparency ledger | P3 | S | F-123 | 5 | H |
| | **FUTURE TOTAL** | | | | **163** | |

---

## 5. Effort rollup

| Category | Features | Dev-weeks | Share | Calendar (9 eng) | Phase mapping |
| --- | --- | --- | --- | --- | --- |
| Must Have | 51 | 257 | 36 percent | ~29 wks | Phases 0 to 1 |
| Should Have | 31 | 199 | 28 percent | ~22 wks | Phases 2 to 3 |
| Could Have | 20 | 94 | 13 percent | ~11 wks | Phases 4 to 5 |
| Future | 15 | 163 | 23 percent | ~18 wks | Phase 6 and beyond |
| **Total** | **117** | **713** | 100 percent | **~80 wks** | - |

| Complexity distribution | Count | Dev-weeks |
| --- | --- | --- |
| S (3 or less) | 48 | 131 |
| M (4 to 8) | 45 | 262 |
| L (9 to 14) | 21 | 240 |
| XL (15 or more) | 3 | 80 |

---

## 6. Critical path

| Order | Chain | Cumulative | Why it gates everything |
| --- | --- | --- | --- |
| 1 | F-001 to F-005 to F-003/F-002 | 18 | Nothing persists or syncs without the data layer |
| 2 | F-020 to F-021 to F-029 | 41 | The mushaf renderer is the single largest engineering artefact |
| 3 | F-006 sync engine | 53 | Blocks bookmarks, Hifz, dashboard, streak integrity, web |
| 4 | F-040 to F-041 | 69 | Verse-sync timing gates Hifz, learning and child modes |
| 5 | F-050 to F-052 to F-055 | 93 | Athan reliability is the most reviewed failure in the category |
| 6 | F-100 to F-101 to F-102 | 121 | The differentiator; cannot start before F-006 stabilises |

**Longest chain is about 121 sequential dev-weeks.** With 9 engineers this compresses to roughly 32 to 36 calendar weeks for Must plus the Hifz epic, because F-024, F-026, F-042, F-077 and F-111 parallelise cleanly off the critical path.

---

## 7. Value versus complexity

| Quadrant | Features | Architectural instruction |
| --- | --- | --- |
| High value, low complexity - do first | F-055, F-075, F-121, F-113, F-130, F-023, F-028, F-073, F-129, F-219 | Disproportionate trust return per week. F-055 and F-121 directly neutralise the two loudest complaints against competitors. |
| High value, high complexity - invest deliberately | F-021, F-006, F-052, F-100, F-122, F-304 | These are the moat. Protect them from scope raids; never staff them thinly. |
| Low value, low complexity - fill gaps | F-211, F-213, F-216, F-217 | Junior-engineer work; never let these displace quadrant 1. |
| Low value, high complexity - resist | F-307, F-312, F-313, F-209 | Deferred to Future with intent. Revisit only on evidenced demand. |

---

## 8. Build versus buy

| Capability | Decision | Rationale |
| --- | --- | --- |
| Prayer time calculation | **Build** on an audited open algorithm | Correctness is non-negotiable and must work offline; no vendor dependency acceptable |
| Mushaf rendering | **Build** | No third party delivers 604-page fidelity across device classes |
| Sync engine | **Build** | Hifz data is sacred; conflict semantics are domain-specific |
| Auth | **Buy** (Firebase) | Commodity, not differentiating |
| Push delivery | **Buy** (FCM/APNs) plus **build** OEM hardening layer | The hardening is where competitors fail |
| Subscription entitlement | **Buy** validation, **build** entitlement service | Offline entitlement caching is a custom requirement |
| Speech recognition (F-304) | **Evaluate both** | On-device is a privacy requirement; may force build if no vendor runs locally |
| Analytics | **Buy**, privacy-configured | Must support full opt-out with zero feature loss |

---

## 9. Architectural risk register

| ID | Risk | Affects | Severity | Mitigation |
| --- | --- | --- | --- | --- |
| AR-1 | Mushaf page-break drift across device pixel ratios | F-021, Hifz recall | Critical | Golden-file test on all 604 pages per device class; CI fails on any diff |
| AR-2 | Android OEM notification suppression | F-052 | Critical | Dedicated OEM matrix in the device farm; F-055 diagnostic as user-facing safety net |
| AR-3 | Sync conflict corrupting Hifz history | F-006, F-100 | Critical | Append-only attempt log; mastery is derived never overwritten; 30-day server backup |
| AR-4 | Content licensing withdrawn post-launch | F-024, F-107, F-111 | High | Versioned content packs allow removal without an app release; never make a licensed asset a hard dependency |
| AR-5 | Flutter web performance on the mushaf renderer | F-122 | High | Web uses a distinct rendering strategy; do not force parity with native |
| AR-6 | Storage exhaustion from audio downloads | F-043 | Medium | Pre-download space check; scoped downloads; F-045 cleanup |
| AR-7 | AI hallucinating a hadith reference | F-300 | Critical | Every citation validated against the content DB before display; unvalidatable answers suppressed, not shown |
| AR-8 | Ad SDK entering the build via a transitive dependency | Premium invariants | High | F-075 dependency-tree assertion in CI; release blocked on failure |

---

## 10. Architect notes

1. **F-075 is the most important three-week investment in this document.** It converts the ad-free, no-guilt, never-paywall-scripture promises from cultural intentions into build-breaking tests. Culture erodes under commercial pressure; CI does not.
2. **F-100 must not begin before F-006 is stable.** The Hifz engine is the differentiator, but it is a consumer of the sync engine conflict semantics. Starting it early to show progress on the moat would embed sync assumptions that later break, and AR-3 is the one risk that would be genuinely unrecoverable in reputation terms.
