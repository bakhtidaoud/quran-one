# Quran One — Product Requirements Document

| Field | Value |
| --- | --- |
| Product | Quran One |
| Document version | 1.0 |
| Status | Draft for review |
| Owner | Product (Daoud Bakhti) |
| Last updated | 2026-07-31 |
| Platforms | Flutter (iOS + Android), Responsive Web |
| Backend | Django REST Framework, PostgreSQL, Redis, Firebase, Cloud Storage |

---

## 1. Vision

**Quran One is the single, trusted home for a Muslim's daily relationship with the Qur'an and with worship.**

Today's Islamic app market is fragmented and compromised. Muslim Pro carries enormous reach but a reputation problem around data practices and an ad-heavy experience. Quran Majeed excels at recitation but feels dated. Athan and Noor each solve slices of the problem. Users end up with three or four apps installed, none of which feels premium, and all of which interrupt an act of worship with a banner ad.

Quran One's vision is a product that a Muslim opens five times a day for decades: fast, beautiful, scholarly rigorous, private by default, and free of anything that cheapens the act of worship. We win not by having the longest feature list, but by making the core loop — read, listen, understand, memorise, pray on time — feel effortless and dignified on every device the user owns.

**Positioning statement:** For practising Muslims who want to build a consistent relationship with the Qur'an, Quran One is a premium Islamic companion that unifies authentic Qur'an study, memorisation, and prayer life in one respectful, ad-free, offline-capable experience — unlike existing apps that fragment these needs and monetise attention during worship.

### Design principles

1. **Reverence over engagement.** No ads, no dark patterns, no gamified guilt. Streaks encourage; they never shame.
2. **Authenticity is non-negotiable.** Every letter of the mushaf, every translation, every hadith is sourced, versioned, and scholar-verified before shipping.
3. **Offline is the default, not a premium unlock.** Worship does not depend on connectivity.
4. **Speed is a feature of worship.** Cold start under two seconds; audio starts in under one.
5. **Privacy as an act of trust.** Minimum data collection, no selling of location or behaviour, ever.
6. **One product, every surface.** Phone, tablet, and web share state seamlessly.

---

## 2. Mission

To help one hundred million Muslims read, understand, memorise, and live by the Qur'an — by building the most trustworthy, beautiful, and accessible Islamic software in the world, and by keeping the core religious experience free for everyone regardless of ability to pay.

---

## 3. Goals

### 3.1 Product goals

| ID | Goal | Rationale |
| --- | --- | --- |
| PG-1 | Deliver a flawless core reading and listening experience before any secondary feature | Competitors lose users on mushaf rendering, audio gaps, and scroll jank |
| PG-2 | Make prayer times and Athan the most accurate and reliable on the market | This is the highest-frequency reason to open an Islamic app |
| PG-3 | Ship a genuinely useful memorisation (Hifz) system based on spaced repetition | No competitor does this well; it is our strongest differentiator |
| PG-4 | Guarantee full offline capability for mushaf, translations, and downloaded audio | Critical in Indonesia, Pakistan, Nigeria, Egypt, rural India |
| PG-5 | Achieve cross-device continuity of bookmarks, progress, and Hifz state | Users read on phone, study on web |
| PG-6 | Remain fully ad-free with a sustainable subscription and Waqf model | The core of our brand promise |

### 3.2 Business goals (first 18 months post-launch)

| Metric | Target |
| --- | --- |
| Registered users | 5,000,000 |
| Monthly active users | 2,000,000 |
| Day-30 retention | ≥ 35% |
| Paid conversion (Quran One Plus) | 4–6% of MAU |
| App Store / Play rating | ≥ 4.8 with > 50,000 reviews |
| Gross margin | ≥ 80% |
| Cost to serve per MAU | < $0.02 / month |

### 3.3 Non-goals for v1

- Social network features (feeds, following, public profiles)
- User-generated tafsir or fatwa answering
- Live-streamed lectures or a video library
- Full Islamic finance or zakat-calculator suite (roadmap, not v1)
- Arabic-language learning curriculum (roadmap)

---

## 4. Target audience

### 4.1 Market

Approximately 2 billion Muslims worldwide; roughly 1.1 billion smartphone-owning. The addressable market for a high-quality Qur'an app is conservatively 400 million users. Existing category leaders have 100M+ installs, proving demand while leaving quality and trust badly underserved.

### 4.2 Primary geographies (launch tiers)

| Tier | Markets | Notes |
| --- | --- | --- |
| Tier 1 (monetisation) | USA, UK, Canada, Gulf states, Germany, France, Australia, Malaysia, Singapore | High ARPU, subscription-ready, strong diaspora demand for translation and transliteration |
| Tier 2 (scale) | Indonesia, Pakistan, Turkey, Egypt, Morocco, Bangladesh, Nigeria | Massive volume, price-sensitive, low-bandwidth and low-end-device constraints |
| Tier 3 (expansion) | India, Central Asia, Balkans, Sub-Saharan Africa | Post-v1 localisation |

### 4.3 Audience segments

1. **Daily reciters** — read a portion each day, want a clean mushaf and reliable audio.
2. **Learners and reverts** — depend on transliteration, word-by-word meaning, and beginner guidance.
3. **Hifz students and teachers** — memorising or supervising memorisation; need repetition tooling and progress tracking.
4. **Prayer-first users** — primarily want accurate prayer times, Athan, and Qibla; discover the Qur'an features later.
5. **Ramadan and seasonal users** — spike in engagement; a large acquisition opportunity and a retention challenge.
6. **Institutions** (roadmap) — madrasas, mosques, Islamic schools needing teacher dashboards.

### 4.4 Accessibility and inclusion requirements

- Full right-to-left (RTL) layout support, not a mirrored afterthought.
- Arabic font scaling to very large sizes for older users, with no reflow bugs.
- Screen-reader support for translations and all navigation (VoiceOver, TalkBack).
- High-contrast and dyslexia-friendly modes for translation text.
- Functional on Android 8 with 2 GB RAM and on 3G connections.

---

## 5. User personas

### Persona 1 — Aisha, "The Consistent Reciter"

| Attribute | Detail |
| --- | --- |
| Age / location | 29, Birmingham, UK |
| Role | Secondary-school teacher, mother of one |
| Devices | iPhone 14, iPad, laptop |
| Tech comfort | High |

**Behaviour.** Reads one page after Fajr and listens to recitation during her commute. Has a Ramadan goal of completing the Qur'an.

**Needs.** A mushaf that looks like her physical copy; resume-where-I-left-off across phone and iPad; background audio that survives a locked screen and a phone call; a gentle daily reminder.

**Pain points.** "Muslim Pro shows me an advert while I'm reading Surah Yaseen." Audio restarts from the beginning after a call. Bookmarks do not sync to her iPad.

**Success looks like.** She opens the app, taps once, and is exactly where she stopped — with zero friction and zero interruption.

---

### Persona 2 — Yusuf, "The Revert Learner"

| Attribute | Detail |
| --- | --- |
| Age / location | 34, Toronto, Canada |
| Role | Software developer, Muslim for 14 months |
| Devices | Pixel 8, Chrome on desktop |
| Tech comfort | Very high |
| Arabic ability | Learning the alphabet; cannot read fluently |

**Behaviour.** Studies short surahs verse by verse, cross-references two translations, and reads tafsir to understand context.

**Needs.** Word-by-word translation and transliteration; audio slow-down for pronunciation; side-by-side translations; reliable tafsir in English; a guided path telling him what to learn next.

**Pain points.** Apps assume Arabic literacy. Transliteration schemes are inconsistent. He cannot tell which translation is trustworthy.

**Success looks like.** He memorises Surah Al-Mulk in six weeks and understands every word he recites.

---

### Persona 3 — Hafiz Bilal, "The Hifz Student"

| Attribute | Detail |
| --- | --- |
| Age / location | 17, Karachi, Pakistan |
| Role | Full-time madrasa student, 12 juz memorised |
| Devices | Mid-range Android (4 GB RAM), intermittent Wi-Fi |
| Tech comfort | Medium |

**Behaviour.** New memorisation each morning, revision (*sabaq*, *sabqi*, *manzil*) throughout the day. His teacher tests him weekly.

**Needs.** Verse-range looping with configurable repeat counts and pauses; hide-text mode to self-test; spaced-repetition revision scheduling; a weakness report showing which verses he consistently stumbles on; complete offline functionality.

**Pain points.** Manual loop setup is tedious. He forgets which of his older juz are decaying. Audio downloads fail on weak connections.

**Success looks like.** The app tells him each morning exactly what to revise, and his weekly test score improves measurably.

---

### Persona 4 — Fatima, "The Prayer-First Professional"

| Attribute | Detail |
| --- | --- |
| Age / location | 41, Dubai, UAE |
| Role | Finance manager |
| Devices | iPhone 15 Pro, Apple Watch |
| Tech comfort | Medium-high |

**Behaviour.** Opens the app mainly for prayer times and Qibla, especially when travelling. Occasionally reads a page before bed.

**Needs.** Accurate times with the correct calculation method for each city she visits; Athan that respects Do Not Disturb rules she chooses; automatic time-zone handling; a widget and watch complication; Qibla that works indoors.

**Pain points.** Times drift when she travels. Athan fires during meetings. Calculation-method settings are buried and jargon-heavy.

**Success looks like.** She never misses a prayer window and never has to think about configuration.

---

### Persona 5 — Ustadh Kamal, "The Teacher" (secondary, roadmap-relevant)

| Attribute | Detail |
| --- | --- |
| Age / location | 45, Cairo, Egypt |
| Role | Qur'an teacher, 30 students |
| Devices | Android tablet, laptop |

**Needs.** Assign memorisation ranges, monitor student progress, share study plans, review recordings. Drives the institutional roadmap and organic acquisition through his classes.

---

## 6. Functional requirements

Priority key: **P0** = required for launch, **P1** = target for launch, ship-blocking only if trivial, **P2** = post-launch.

### 6.1 Onboarding and account (FR-100)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-101 | Full app usable anonymously with local-only data; no forced sign-up | P0 |
| FR-102 | Optional account via Apple, Google, and email (Firebase Auth); anonymous data migrates on sign-in | P0 |
| FR-103 | Onboarding captures language, Arabic reading ability, primary goal (read / understand / memorise / prayer), location permission with clear rationale | P0 |
| FR-104 | Onboarding completes in under 60 seconds and is fully skippable | P0 |
| FR-105 | Account deletion removes all server-side data within 30 days, self-service in-app | P0 |
| FR-106 | Guest-to-account merge conflict resolution (last-write-wins per field, with Hifz state union) | P1 |

### 6.2 Qur'an reader (FR-200)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-201 | Uthmani mushaf, 604-page Madani layout, page-faithful line breaks | P0 |
| FR-202 | Two reading modes: **Mushaf** (page images / vector glyphs, swipe) and **Verse list** (scrollable, translation-friendly) | P0 |
| FR-203 | Navigation by surah, juz, hizb, page, and ruku; jump-to-verse input | P0 |
| FR-204 | Verified Arabic text versioned against a canonical source (Tanzil / King Fahd Complex), with checksum validation on device | P0 |
| FR-205 | At least 25 translations at launch, including 5 English, Urdu, French, Indonesian, Turkish, Bengali, Malay, German, Spanish, Russian | P0 |
| FR-206 | Up to 3 simultaneous translations displayed | P1 |
| FR-207 | Transliteration (single consistent scheme, documented) | P0 |
| FR-208 | Word-by-word translation and morphological breakdown, tap a word for root, grammar, and occurrences | P1 |
| FR-209 | Tafsir integration: Ibn Kathir, Tafsir al-Jalalayn, Ma'ariful Qur'an, Tafsir as-Sa'di (per-language availability) | P1 |
| FR-210 | Verse actions: bookmark, note, highlight (5 colours), copy, share as image, share as text with reference | P0 |
| FR-211 | Typography controls: Arabic font family (min 3 including Uthmani Hafs and IndoPak), Arabic size, translation size, line spacing | P0 |
| FR-212 | Themes: light, sepia, dark, true-black (OLED); automatic switching | P0 |
| FR-213 | Tajweed colour-coding, toggleable, with a legend | P1 |
| FR-214 | Sajdah, waqf, and juz markers rendered correctly | P0 |
| FR-215 | Full-text search across Arabic (diacritic-insensitive), translations, and notes; sub-300 ms local results | P0 |
| FR-216 | Reading history and "continue reading" entry point on home | P0 |
| FR-217 | Reading plans (e.g. Qur'an in 30 / 60 / 365 days, Ramadan plan) with daily targets and progress | P1 |
| FR-218 | Tablet and web two-page spread layout | P1 |

### 6.3 Audio and recitation (FR-300)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-301 | Minimum 15 reciters at launch (Abdul Basit, Mishary Alafasy, Maher Al-Muaiqly, Saad Al-Ghamdi, Al-Husary, Minshawi, Sudais, Shatri, Yasser Al-Dosari, and others), each in at least 64 kbps and 128 kbps | P0 |
| FR-302 | Verse-synchronised highlighting during playback, accurate to ±150 ms | P0 |
| FR-303 | Background playback with lock-screen and notification controls, CarPlay and Android Auto metadata | P0 |
| FR-304 | Playback speed 0.5×–2.0× with pitch preservation | P0 |
| FR-305 | Repeat engine: repeat verse *n* times, repeat range, repeat surah, configurable inter-repetition pause (0–10 s) | P0 |
| FR-306 | Continuous playback across surah boundaries with gapless transitions | P0 |
| FR-307 | Selective offline download per reciter by surah, juz, or full Qur'an, with pause / resume / integrity check | P0 |
| FR-308 | Storage manager showing per-reciter usage and one-tap cleanup | P0 |
| FR-309 | Translation audio (English, Urdu) | P2 |
| FR-310 | Sleep timer and "stop at end of surah" | P1 |
| FR-311 | Recording and self-playback for pronunciation comparison | P2 |
| FR-312 | AI-assisted recitation feedback (tajweed / mistake detection) | P2 (roadmap) |

### 6.4 Memorisation — Hifz (FR-400)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-401 | Create a memorisation plan by surah, juz, or custom verse range with a target date | P0 |
| FR-402 | Hifz mode with progressive text hiding: full text → first word only → hidden, per verse | P0 |
| FR-403 | Spaced-repetition scheduler (SM-2 derived, tuned for verse recall) generating a daily revision queue | P0 |
| FR-404 | Per-verse mastery state (new, learning, review, mastered, weak) with confidence self-rating after each attempt | P0 |
| FR-405 | Structured revision categories mapping to madrasa practice: *sabaq*, *sabqi*, *manzil* | P1 |
| FR-406 | Weakness report identifying verses with the lowest recall accuracy | P1 |
| FR-407 | Hifz statistics: verses memorised, juz completed, revision streak, projected completion date | P0 |
| FR-408 | Full Hifz functionality offline, with sync on reconnect | P0 |
| FR-409 | Export progress as PDF for a teacher | P2 |
| FR-410 | Teacher–student linking and assignment | P2 (roadmap) |

### 6.5 Prayer times, Athan, and Qibla (FR-500)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-501 | Prayer times computed on-device (Adhan library) so no connectivity is required after first location fix | P0 |
| FR-502 | All major calculation methods (MWL, ISNA, Egyptian, Umm al-Qura, Karachi, Tehran, Kuwait, Qatar, Singapore, Turkey, Moonsighting Committee, Dubai) plus manual angle entry | P0 |
| FR-503 | Asr juristic method (Hanafi / Shafi'i) and high-latitude rules (middle of night, one-seventh, angle-based) | P0 |
| FR-504 | Per-prayer manual offset in minutes | P0 |
| FR-505 | Automatic location and time-zone detection with travel handling; manual city override | P0 |
| FR-506 | Athan notifications with selectable muadhin audio, silent, or vibrate; per-prayer configuration | P0 |
| FR-507 | Pre-prayer reminder (configurable 5–60 minutes before) | P0 |
| FR-508 | Iqamah reminder after Athan | P1 |
| FR-509 | Home-screen widgets (iOS and Android) showing next prayer and countdown; Apple Watch and Wear OS complications | P1 |
| FR-510 | Qibla compass with magnetometer, calibration guidance, and map-based fallback | P0 |
| FR-511 | Monthly prayer timetable view, exportable and printable | P1 |
| FR-512 | Hijri calendar with adjustable offset, key Islamic dates, fasting-day reminders (Monday/Thursday, Ayyam al-Bid) | P1 |
| FR-513 | Prayer tracker (logged as prayed / missed / qada) with private history | P1 |
| FR-514 | Nearby mosque finder | P2 |

### 6.6 Duas and adhkar (FR-600)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-601 | Curated dua library (Hisnul Muslim / Fortress of the Muslim) with Arabic, transliteration, translation, and source reference | P0 |
| FR-602 | Morning and evening adhkar with a guided counter | P0 |
| FR-603 | Digital tasbih with haptic feedback and configurable target counts | P1 |
| FR-604 | Dua audio | P1 |
| FR-605 | Favourite and custom dua collections | P1 |
| FR-606 | Contextual dua suggestions (travel, illness, before sleep) | P2 |

### 6.7 Sync, offline, and cross-device (FR-700)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-701 | Offline-first local database; every read feature works with zero connectivity after initial content download | P0 |
| FR-702 | Sync of bookmarks, notes, highlights, reading progress, Hifz state, settings, and prayer configuration | P0 |
| FR-703 | Deterministic conflict resolution with per-entity timestamps and a documented merge policy | P0 |
| FR-704 | Delta sync only; a typical sync payload under 50 KB | P0 |
| FR-705 | Web app reaches feature parity for reading, listening, search, and Hifz review | P1 |
| FR-706 | Data export (JSON) and import | P2 |

### 6.8 Personalisation, home, and engagement (FR-800)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-801 | Home screen showing next prayer, continue reading, today's Hifz queue, verse of the day | P0 |
| FR-802 | Verse of the day with share-as-image | P0 |
| FR-803 | Reading streak and gentle, non-punitive encouragement | P1 |
| FR-804 | Configurable daily reminders (reading, adhkar, Hifz) with quiet hours | P0 |
| FR-805 | Ramadan mode: suhoor and iftar countdown, taraweeh plan, seasonal home layout | P1 |
| FR-806 | Notification centre respecting a global "reduce notifications" setting | P0 |

### 6.9 Monetisation (FR-900)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-901 | Zero advertising anywhere in the product, permanently | P0 |
| FR-902 | Free tier includes the full mushaf, all translations, transliteration, search, prayer times, Athan, Qibla, duas, and at least 5 reciters with offline download | P0 |
| FR-903 | **Quran One Plus** subscription (monthly / annual / lifetime) unlocking all reciters, unlimited high-bitrate downloads, advanced Hifz analytics, full tafsir library, unlimited notes and highlights, premium fonts and themes, and web-app sync | P0 |
| FR-904 | Regional pricing with purchasing-power parity across Tier 2 and Tier 3 markets | P0 |
| FR-905 | Sponsored / gifted subscriptions: users can fund access for those who cannot pay (Waqf model), with transparent reporting | P1 |
| FR-906 | In-app receipt validation server-side; entitlement cached for 30 days offline | P0 |
| FR-907 | No paywall may ever block the Arabic text of the Qur'an or the five daily prayer times | P0 |

### 6.10 Content management and integrity (FR-1000)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-1001 | Django admin CMS for translations, tafsir, reciters, duas, and content packs | P0 |
| FR-1002 | Content versioning with staged rollout and instant rollback | P0 |
| FR-1003 | Scholar review workflow: no religious content reaches production without recorded approval by a named reviewer | P0 |
| FR-1004 | Cryptographic integrity check of Qur'anic text bundles on every app launch | P0 |
| FR-1005 | In-app error reporting for content issues, routed to the review board | P0 |
| FR-1006 | Licence tracking per translation and reciter, with attribution surfaced in-app | P0 |

---

## 7. Non-functional requirements

### 7.1 Performance

| ID | Requirement |
| --- | --- |
| NFR-101 | Cold start to interactive: < 2.0 s on a mid-range Android (Snapdragon 6-series, 4 GB RAM); < 1.2 s on iPhone 12 or newer |
| NFR-102 | Mushaf page turn: sustained 60 fps, no dropped frames above 1% |
| NFR-103 | Audio start latency: < 500 ms cached, < 1.5 s streaming on 4G |
| NFR-104 | Local search results: < 300 ms for a 3-character query |
| NFR-105 | API p95 latency < 300 ms, p99 < 800 ms |
| NFR-106 | Base install size < 60 MB (Android app bundle); core offline content pack < 250 MB |
| NFR-107 | Battery: < 2% drain per hour of screen-on reading; < 0.5% per day for prayer-time background work |
| NFR-108 | Web: Largest Contentful Paint < 2.5 s, Cumulative Layout Shift < 0.1, Interaction to Next Paint < 200 ms on a 4G connection |

### 7.2 Reliability and availability

| ID | Requirement |
| --- | --- |
| NFR-201 | Backend availability 99.9% monthly (99.95% target during Ramadan) |
| NFR-202 | Athan notification delivery reliability ≥ 99.5%, verified by automated device-farm testing across OS versions and battery-saver states |
| NFR-203 | Crash-free sessions ≥ 99.7%; crash-free users ≥ 99.5% |
| NFR-204 | Graceful degradation: complete read, listen (downloaded), prayer, and Hifz functionality during a total backend outage |
| NFR-205 | Recovery Point Objective 15 minutes; Recovery Time Objective 1 hour; automated PostgreSQL point-in-time recovery, restores tested quarterly |
| NFR-206 | Ramadan readiness: infrastructure load-tested to 5× peak projected traffic; capacity plan frozen four weeks before Ramadan |

### 7.3 Scalability and architecture

| ID | Requirement |
| --- | --- |
| NFR-301 | Support 10 million MAU and 500,000 concurrent users without architectural rewrite |
| NFR-302 | Stateless Django REST API behind a load balancer, horizontally auto-scaled |
| NFR-303 | PostgreSQL primary with read replicas; partitioning for high-volume tables (sync events, Hifz attempts) |
| NFR-304 | Redis for caching, rate limiting, session and entitlement caching, and Celery brokering; cache hit ratio > 90% on content endpoints |
| NFR-305 | Static and audio content served exclusively from Cloud Storage via CDN with long-lived immutable cache headers and range-request support |
| NFR-306 | Celery workers for asynchronous jobs (content indexing, notification fan-out, analytics rollups, receipt validation retries) |
| NFR-307 | API versioned under `/api/v1/`; no breaking change without a 12-month deprecation window, since old app versions persist for years |
| NFR-308 | Infrastructure as code; reproducible environments for dev, staging, and production |

### 7.4 Security

| ID | Requirement |
| --- | --- |
| NFR-401 | TLS 1.3 everywhere; HSTS; certificate pinning on mobile |
| NFR-402 | Firebase Auth with short-lived JWT access tokens and rotating refresh tokens; server-side revocation |
| NFR-403 | Encryption at rest for all databases, backups, and object storage |
| NFR-404 | Per-user and per-IP rate limiting on all write and auth endpoints |
| NFR-405 | OWASP Mobile Top 10 and API Top 10 addressed; third-party penetration test before public launch and annually thereafter |
| NFR-406 | Secrets in a managed secret store; no credentials in source control; automated secret scanning in CI |
| NFR-407 | Signed, expiring URLs for premium audio downloads |
| NFR-408 | Audit logging for all admin and content-publishing actions |

### 7.5 Privacy

| ID | Requirement |
| --- | --- |
| NFR-501 | Data minimisation: collect only what a feature requires; location processed on-device and never stored server-side in raw form |
| NFR-502 | No sale or brokering of user data, ever; contractually binding and stated publicly |
| NFR-503 | GDPR, CCPA, UK GDPR, and PDPA compliance: export, rectification, deletion, and consent records |
| NFR-504 | Analytics anonymised and aggregate; opt-out available without feature loss |
| NFR-505 | Reading history, notes, Hifz progress, and prayer tracker treated as sensitive religious data with elevated protection |
| NFR-506 | Plain-language privacy policy, readable in under five minutes, presented during onboarding |
| NFR-507 | Third-party SDKs audited and minimised; no advertising or data-broker SDKs permitted in the build |

### 7.6 Usability, accessibility, and localisation

| ID | Requirement |
| --- | --- |
| NFR-601 | WCAG 2.2 Level AA on web; equivalent standards on mobile |
| NFR-602 | Full VoiceOver and TalkBack support for navigation, translations, and controls |
| NFR-603 | Complete RTL layout support for Arabic, Urdu, Farsi, and Hebrew-script locales |
| NFR-604 | Minimum touch target 44 × 44 pt; one-handed reachability for core reading controls |
| NFR-605 | UI localised into at least 12 languages at launch; all strings externalised, no hard-coded copy |
| NFR-606 | Respect OS-level text scaling up to 200% without layout breakage |
| NFR-607 | Dynamic type and reduced-motion preferences honoured |

### 7.7 Content and religious integrity

| ID | Requirement |
| --- | --- |
| NFR-701 | Qur'anic Arabic text byte-identical to the approved canonical source; verified by checksum in CI and on device |
| NFR-702 | Every translation, tafsir, dua, and hadith carries a visible source and translator attribution |
| NFR-703 | A standing scholarly review board approves all religious content before release; approvals recorded and auditable |
| NFR-704 | The product presents no sectarian editorialising; differences in juristic method are offered as user settings, not defaults imposed silently |
| NFR-705 | Reported content errors triaged within 48 hours and, if confirmed, hot-fixed via content update without an app release |

### 7.8 Maintainability and quality

| ID | Requirement |
| --- | --- |
| NFR-801 | Unit test coverage ≥ 80% on business logic (Flutter and Django) |
| NFR-802 | Automated integration tests for sync, entitlement, prayer-time calculation, and audio playback |
| NFR-803 | Golden-file tests for mushaf rendering across device classes |
| NFR-804 | CI on every pull request: lint, test, build, secret scan, dependency audit |
| NFR-805 | Staged mobile rollouts (5% → 25% → 100%) with automated crash-rate rollback triggers |
| NFR-806 | Feature flags for all significant new functionality |
| NFR-807 | Observability: structured logging, distributed tracing, error tracking, and dashboards for the Athan delivery and sync pipelines |

---

## 8. User flows

### 8.1 First-run onboarding

```text
Launch
  └─ Splash (< 1s, integrity check)
     └─ Welcome: "Your Qur'an, everywhere. No ads. Ever."
        └─ Language selection (device default pre-selected)
           └─ "Can you read Arabic?"  → Fluently / Some / Not yet
              │   (Not yet → transliteration + word-by-word enabled by default)
              └─ "What matters most right now?"
                 → Read daily / Understand deeply / Memorise / Never miss a prayer
                    └─ Location permission (with rationale screen, skippable)
                       │   Granted   → detect city, calculation method by region
                       │   Skipped   → manual city picker
                       └─ Recommended offline pack (size shown, one-tap or skip)
                          └─ Optional sign-in ("Sync across devices" / "Not now")
                             └─ Home
```

Constraint: every step after language is skippable; median completion under 60 seconds.

### 8.2 Daily reading

```text
Home
  └─ "Continue reading — Surah Al-Baqarah, page 42"
     └─ Mushaf opens at exact last position
        ├─ Swipe → next page (60 fps, prefetched)
        ├─ Long-press verse → action sheet
        │     Bookmark · Note · Highlight · Play from here · Share image · Tafsir · Copy
        ├─ Tap centre → chrome toggles (immersive reading)
        └─ Tap Play → audio starts, verse highlight follows recitation
              └─ Exit app → playback continues, lock-screen controls active
                    └─ Return later → "Resume from Al-Baqarah 2:45?"
```

Position is persisted locally on every page change and synced on a debounce.

### 8.3 Hifz daily session

```text
Home → "Hifz: 12 verses due today"
  └─ Session summary (New 3 · Sabaq 4 · Sabqi 3 · Manzil 2)
     └─ Verse 1 presented
        ├─ Listen (auto-loops per user's repeat setting)
        ├─ Tap "Hide" → progressive reveal (full → first word → hidden)
        ├─ Recite from memory
        └─ Self-rate: Again · Hard · Good · Easy
              └─ Scheduler updates interval + mastery state (written locally first)
                 └─ Next verse … repeat until queue empty
                    └─ Session complete
                       Summary: accuracy, streak, next session preview,
                       weak verses flagged for tomorrow
                       └─ Sync when connectivity returns
```

### 8.4 Prayer time and Athan

```text
App start / location change / midnight rollover
  └─ On-device calculation (Adhan) using saved method + offsets
     └─ Schedule OS-level local notifications for the next 7 days
        └─ Athan fires at prayer time
           ├─ Selected muadhin audio (respects silent / vibrate settings)
           ├─ Notification actions: Open Qibla · Mark as prayed · Snooze 10 min
           └─ Tap → Prayer screen (time, remaining window, Qibla, tracker)

Travel detected (time zone or > 100 km change)
  └─ Non-blocking banner: "You appear to be in Istanbul. Update prayer times?"
     → Update / Keep current
```

Notifications are scheduled locally, so Athan works with the device fully offline.

### 8.5 Learner studying a verse (Yusuf)

```text
Search "mulk" → Surah Al-Mulk
  └─ Verse list mode (translation + transliteration visible)
     └─ Tap verse 1 → Study panel
        ├─ Word-by-word: tap any word → root, grammar, other occurrences
        ├─ Translations: compare up to 3 side by side
        ├─ Tafsir: Ibn Kathir (English)
        ├─ Audio: 0.75× speed, repeat 5×, 2 s pause between repeats
        └─ "Add to Hifz plan" → target date → plan created
```

### 8.6 Offline download

```text
Settings → Downloads → Reciters → Mishary Alafasy
  └─ Scope: Full Qur'an (1.2 GB) · By juz · By surah
     └─ Quality: Standard 64 kbps (620 MB) · High 128 kbps (1.2 GB)
        └─ "Wi-Fi only" toggle (on by default)
           └─ Download queued → resumable, integrity-verified per file
              ├─ Connection lost → auto-resume on reconnect
              └─ Storage low → warn before starting, suggest cleanup
```

### 8.7 Subscription

```text
User taps a locked reciter
  └─ Value screen — what Plus includes, what stays free forever
     └─ Plans: Monthly · Annual (best value) · Lifetime   [regionally priced]
        ├─ "Can't afford it?" → sponsored access request (Waqf pool)
        └─ Purchase → store flow → server-side receipt validation
           └─ Entitlement written to Redis + local cache (valid 30 days offline)
              └─ Content unlocks immediately, no restart
```

The paywall never appears over Arabic Qur'anic text or prayer times.

### 8.8 Cross-device continuity

```text
Phone: reads to page 42, adds note on 2:255, completes Hifz session
  └─ Local write → delta queued
     └─ Sync (debounced, or on background / foreground transition)
        └─ Server merges, bumps per-entity version
           └─ Web: sign in → pulls delta → opens at page 42, note present,
              Hifz queue reflects the phone session
```

Conflict policy: last-write-wins per field; Hifz attempt logs are additive (never overwritten); deletions use tombstones.

---

## 9. Success metrics

### 9.1 North Star

**Weekly Engaged Muslims (WEM)** — weekly active users who complete at least one meaningful worship action (read ≥ 1 page, listen ≥ 5 minutes, complete a Hifz session, or log a prayer). This measures genuine religious utility rather than app-opening.

### 9.2 Acquisition and growth

| Metric | Launch target | Month 12 |
| --- | --- | --- |
| Installs | 250,000 (first 90 days) | 5,000,000 |
| Organic share of installs | > 60% | > 70% |
| Store rating | ≥ 4.7 | ≥ 4.8 |
| Onboarding completion | > 85% | > 90% |
| K-factor (share-driven installs) | 0.15 | 0.30 |

### 9.3 Engagement

| Metric | Target |
| --- | --- |
| DAU / MAU ratio | ≥ 40% (prayer times drive daily habit) |
| Median sessions per day | ≥ 3 |
| Median reading minutes per active day | ≥ 8 |
| Weekly Hifz-active users (of MAU) | ≥ 12% |
| Athan enabled | ≥ 70% of MAU |
| Offline pack downloaded | ≥ 50% of MAU |

### 9.4 Retention

| Metric | Target |
| --- | --- |
| Day 1 | ≥ 60% |
| Day 7 | ≥ 45% |
| Day 30 | ≥ 35% |
| Day 90 | ≥ 25% |
| Post-Ramadan retention (Ramadan cohort at day 60) | ≥ 30% |
| 12-month retention of Hifz-active users | ≥ 50% |

### 9.5 Monetisation

| Metric | Target |
| --- | --- |
| Free → Plus conversion | 4–6% of MAU |
| Annual plan share of new subscriptions | ≥ 55% |
| Subscription 12-month renewal | ≥ 65% |
| Involuntary churn | < 5% |
| Sponsored subscriptions funded | ≥ 50,000 in year one |
| LTV : CAC | ≥ 3 : 1 |

### 9.6 Quality and trust

| Metric | Target |
| --- | --- |
| Crash-free sessions | ≥ 99.7% |
| Athan delivery success | ≥ 99.5% |
| Sync conflict error rate | < 0.1% of syncs |
| Confirmed content errors reaching production | 0 in Qur'anic Arabic text; < 5 per quarter in translations |
| Content-error fix time | < 48 hours |
| App Store reviews mentioning ads or privacy negatively | < 0.5% of reviews |
| Support first-response time | < 24 hours |

### 9.7 Instrumentation requirements

- Every metric above must have a named owner, a defined event schema, and a dashboard before the feature ships.
- Analytics events must be privacy-preserving and aggregate; no verse-level reading history leaves the device in identifiable form.
- A/B testing framework required for onboarding, paywall, and reminder copy — never for religious content.

---

## 10. Risks

### 10.1 Risk register

| ID | Risk | Category | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- | --- | --- |
| R-1 | An error in Qur'anic Arabic text reaches production | Religious / reputational | Low | Critical | Canonical source, checksum verification in CI and on-device, scholar sign-off, immutable text pipeline separate from all other content, staged rollout with instant rollback |
| R-2 | Translation or tafsir perceived as sectarian or mistranslated | Religious / reputational | Medium | High | Standing multi-madhhab review board, visible attribution, user-selectable rather than imposed defaults, 48-hour error triage |
| R-3 | Athan notifications suppressed by aggressive OS battery management (Xiaomi, Oppo, Huawei, Samsung) | Technical | High | High | Local notification scheduling, per-OEM guidance in-app, automated device-farm verification matrix, in-app diagnostic "test my Athan" tool, fallback exact-alarm permissions |
| R-4 | Incumbents (Muslim Pro, Quran Majeed) copy differentiating features | Competitive | High | Medium | Compete on trust, performance, and Hifz depth — hard to copy quickly; build brand as the privacy-respecting choice; ship faster |
| R-5 | Subscription conversion too low to sustain an ad-free model | Business | Medium | Critical | Generous free tier drives scale and word of mouth; regional pricing; Waqf sponsorship pool; lifetime tier for high-intent users; keep cost-to-serve under $0.02/MAU |
| R-6 | Audio CDN egress costs scale faster than revenue | Business / technical | Medium | High | Aggressive offline-download promotion (a download replaces repeat streaming), tiered bitrates, immutable long-cache headers, negotiated CDN commit pricing, per-user fair-use limits on high-bitrate downloads |
| R-7 | Ramadan traffic spike causes an outage during the highest-visibility period of the year | Technical | Medium | Critical | 5× load testing, capacity freeze four weeks before Ramadan, offline-first design so outages degrade rather than break, on-call rotation with Ramadan runbooks |
| R-8 | Content licensing dispute over a translation or reciter recording | Legal | Medium | High | Written licences before ingestion, licence tracking in the CMS, per-item takedown capability without an app release, legal review of all Tier 1 content |
| R-9 | Location or religious-practice data misused or breached | Privacy / legal | Low | Critical | On-device location processing, data minimisation, encryption at rest and in transit, annual penetration testing, no ad SDKs, elevated protection for religious data |
| R-10 | Mushaf rendering inconsistency across devices, fonts, and OS versions | Technical / religious | High | High | Vector glyph rendering with bundled fonts, golden-file tests per device class, page-faithful layout validation against the printed Madani mushaf |
| R-11 | Feature scope overwhelms the launch and delays quality | Execution | High | High | Strict P0 gate; reader, audio, prayer, and Hifz core must be excellent before anything else ships; explicit non-goals |
| R-12 | Offline content size deters users on low-end devices | Product | Medium | Medium | Granular download scopes, 64 kbps standard tier, storage manager, text-only offline mode under 60 MB |
| R-13 | App store policy issues around religious content or subscription terms | Legal / distribution | Low | High | Compliance review before submission, clear subscription disclosures, no external-payment steering in-app |
| R-14 | Cross-device sync data loss (a user's Hifz progress or notes) | Technical / trust | Medium | Critical | Local-first writes, additive Hifz logs, tombstone deletions, server-side versioned history, restorable 30-day backup of user sync state |
| R-15 | Key-person dependency on scholarly reviewers | Organisational | Medium | Medium | Panel of at least three reviewers per language, documented review criteria, no single-reviewer approval path |

### 10.2 Launch-blocking conditions

The product will not ship publicly unless **all** of the following hold:

- Qur'anic Arabic text verified and signed off by the review board, with checksum enforcement live.
- Athan delivery ≥ 99.5% verified across the OEM test matrix.
- Crash-free sessions ≥ 99.7% in the beta cohort.
- Complete offline reading and prayer functionality with the network disabled.
- Sync tested for data loss across 10,000 simulated conflict scenarios with zero loss.
- Penetration test completed with no unresolved high or critical findings.
- Privacy policy published and legally reviewed for all launch markets.

---

## 11. Future roadmap

### Phase 0 — Foundations (months 1–3)

Architecture and content pipeline. Django REST API skeleton, PostgreSQL schema, Redis caching, Firebase Auth, Cloud Storage and CDN topology, Flutter app shell and design system, canonical Qur'an text ingestion with integrity verification, scholarly review workflow, CI/CD with staged rollout.

**Exit criteria:** verified Qur'an text renders page-faithfully in the app; CI green; content pipeline publishes to staging.

### Phase 1 — Core reader and prayer (months 4–7) → Closed beta

Mushaf and verse-list reading, navigation, bookmarks, notes, highlights, search, 25 translations, transliteration, 15 reciters with verse-sync and offline download, on-device prayer times with all calculation methods, Athan, Qibla, duas and adhkar, offline-first local database.

**Exit criteria:** all P0 items in §6.2, §6.3, §6.5, §6.6 complete; NFR performance budgets met on the reference mid-range Android.

### Phase 2 — Hifz and sync (months 8–10) → Open beta

Spaced-repetition memorisation engine, progressive hide mode, revision categories, Hifz statistics and weakness reports, cross-device sync, account system, responsive web app (reading, listening, search), widgets and watch complications.

**Exit criteria:** zero-data-loss sync validation; Hifz retention measurably better than manual repetition in beta cohort testing.

### Phase 3 — Launch (months 11–12) → Public 1.0

Word-by-word translation and morphology, tafsir library, reading plans, Ramadan mode, prayer tracker, Hijri calendar, subscription and entitlement system with regional pricing and the Waqf sponsorship pool, 12 UI languages, accessibility certification, penetration test, launch marketing.

**Exit criteria:** every launch-blocking condition in §10.2 satisfied.

### Phase 4 — Depth (months 13–18)

- Recitation recording and self-comparison
- Tajweed learning module with interactive lessons
- Translation audio (English, Urdu)
- Nearby mosque finder and community prayer times
- Advanced thematic index and topical Qur'an navigation
- Hadith collections (Bukhari, Muslim, and the Sunan) with grading and attribution
- Expanded tafsir and 15 additional translations
- Data export and import

### Phase 5 — Intelligence and institutions (months 19–30)

- AI-assisted recitation feedback: tajweed and mistake detection with on-device inference where feasible
- Personalised study paths adapting to comprehension and recall data
- Teacher and student accounts: assignments, progress dashboards, recording review
- Institutional licensing for madrasas, mosques, and Islamic schools
- Family accounts with child-appropriate modes and parental oversight
- Arabic-language learning track integrated with the Qur'an corpus
- Semantic search over the Qur'an, tafsir, and hadith, with citations always shown and no generated religious rulings

### Phase 6 — Ecosystem (months 30+)

- Native iPadOS, macOS, and desktop-class experiences
- Public API and developer platform for the Islamic-tech ecosystem
- Open-sourcing of non-differentiating infrastructure and the verified content-integrity tooling
- Endowment (Waqf) structure to guarantee the free tier exists permanently, independent of commercial performance

### Roadmap principles

1. No phase ships until the previous phase's quality bar is met.
2. AI features must never generate religious rulings or replace scholarly authority; they assist, cite, and defer.
3. Every phase reserves at least 20% of capacity for performance, accessibility, and technical debt.
4. The free tier only ever grows. Features never move from free to paid.

---

## Appendix A — Technical architecture summary

| Layer | Technology | Responsibility |
| --- | --- | --- |
| Mobile | Flutter (iOS + Android) | Single codebase; custom mushaf rendering; local database; on-device prayer calculation; local notification scheduling |
| Web | Responsive web (shared design system) | Reading, listening, search, Hifz review; SEO-friendly public surahs |
| API | Django + Django REST Framework | Content delivery, sync, entitlements, admin CMS, scholar review workflow |
| Primary datastore | PostgreSQL | Users, content metadata, sync state, Hifz records, subscriptions |
| Cache / queue | Redis | Content caching, rate limiting, entitlement cache, Celery broker |
| Async | Celery workers | Notification fan-out, indexing, analytics rollups, receipt validation |
| Auth / messaging | Firebase | Authentication, push messaging, remote config, feature flags |
| Object storage | Cloud Storage + CDN | Audio, mushaf assets, content packs; signed URLs for premium content |
| Observability | Structured logs, tracing, error tracking | SLO dashboards for Athan delivery, sync integrity, API latency |

## Appendix B — Open questions

| # | Question | Owner | Needed by |
| --- | --- | --- | --- |
| 1 | Which canonical Arabic text edition is authoritative for v1 — Tanzil or King Fahd Complex digital release? | Product + review board | Phase 0 |
| 2 | Which reciter recordings can be licensed for commercial redistribution, and at what cost? | Legal / BD | Phase 0 |
| 3 | Is the mushaf rendered from page images, or fully from vector glyph fonts? (Cost, fidelity, and size trade-off) | Engineering | Phase 0 |
| 4 | Composition of the scholarly review board — how many reviewers per language, and what governance? | Founder | Phase 0 |
| 5 | Exact regional price ladder and Waqf pool mechanics | Product + Finance | Phase 3 |
| 6 | Web app rendering approach for the mushaf given font licensing constraints | Engineering | Phase 2 |
| 7 | Should the prayer tracker be entirely on-device only, given the sensitivity of missed-prayer data? | Product + Privacy | Phase 3 |
