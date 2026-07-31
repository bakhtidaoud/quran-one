# Quran One - UX Research: User Personas

| Field | Value |
| --- | --- |
| Document | UX research personas |
| Version | 1.0 |
| Author | UX Research |
| Date | 2026-07-31 |
| Companion documents | docs/PRD.md, docs/COMPETITOR_ANALYSIS.md |
| Personas | 8 primary |

---

## How to use this document

These are design personas, not marketing segments. Each one exists to answer a specific design question that recurs in product decisions, and each carries a decision rule that the team can apply without re-litigating the research.

**Method note.** These personas are synthesised from competitor review analysis (App Store, Google Play, Trustpilot, Reddit sampling across Muslim Pro, Quran Majeed, Athan, Quranly, Pillars, Ayah, Noor), published app behaviour, and category conventions. They are evidence-informed hypotheses, not validated ethnography. Before Phase 1 exit they should be tested against a minimum of 40 interviews (5 per persona) and revised. Confidence levels are stated per persona.

**Priority tiers.**

| Tier | Personas | Meaning |
| --- | --- | --- |
| Primary | Sara (Beginner), Hafiz Bilal (Hafiz), Amina (Busy Professional) | Design conflicts resolve in their favour |
| Secondary | Yusuf (New Muslim), Khadija (Parent), Ibrahim (Student of Knowledge) | Fully supported, but do not override primary |
| Tertiary | Zayd (Child), Shaykh Musa (Imam) | Served deliberately but scoped; drive roadmap phases 4-5 |

---

## Persona 1 - Sara Rahman, the Beginner Muslim

**Primary. Confidence: high.**

| Attribute | Detail |
| --- | --- |
| Age | 24 |
| Location | Manchester, UK |
| Occupation | Retail supervisor |
| Background | Born Muslim, Pakistani heritage, culturally observant family |
| Arabic ability | Can decode letters slowly; cannot read fluently; does not understand meaning |
| Devices | Samsung Galaxy A34 (mid-range Android, 4GB RAM), no tablet |
| Connectivity | Mobile data with a monthly cap; Wi-Fi at home |
| Current apps | Muslim Pro (installed years ago), YouTube for recitation |

### Context

Sara prays most days and wants a real relationship with the Qur'an, but she carries a quiet shame about her Arabic. She learned to recite as a child at weekend madrasa, never learned meaning, and stopped at around age eleven. She feels she should be further along than she is, and any product surface that reminds her of that gap causes her to close the app.

### Goals

1. Read a small amount of Qur'an consistently without feeling like a fraud.
2. Understand what she is reciting, at least in outline.
3. Rebuild her Arabic reading fluency slowly and privately.
4. Stop missing Asr, which falls during her shift.
5. Feel that she is progressing, with evidence.

### Frustrations

- Apps assume she can read Arabic fluently and give her no ramp.
- Transliteration schemes are inconsistent between apps and sometimes within one app.
- She cannot tell which translation is trustworthy; the choice list is intimidating and unexplained.
- Ads appear while she is reading, which she experiences as disrespectful.
- Streak language that says she failed makes her delete the app rather than return.
- Her phone is mid-range; heavier apps stutter when she scrolls the mushaf.
- Storage anxiety: she deletes apps that download large audio files without warning her.

### Daily habits

| Time | Behaviour |
| --- | --- |
| 06:30 | Wakes, checks phone in bed, prays Fajr late roughly half the week |
| 08:00 | Commute by bus, 25 minutes, headphones in |
| 13:00 | Lunch break, 30 minutes, phone in hand |
| 15:30 | Asr falls mid-shift; frequently missed |
| 21:30 | Winds down, this is her most reliable reading window |
| 22:30 | Scrolls social media, sleeps |

Her real reading window is 10 to 15 minutes at night, on a phone, often tired.

### Technical skills

Competent consumer. Fluent with Instagram, WhatsApp, banking apps, and Netflix. Will not navigate a settings tree, will not read documentation, will not troubleshoot a notification permission. If a feature requires configuration, it does not exist for her.

### Needs

| Need | Product implication |
| --- | --- |
| A defensible starting point | Onboarding that asks Arabic ability without judgement and configures itself accordingly |
| Transliteration on by default for her profile | One consistent, documented scheme, never mixed |
| Guidance on translation choice | A recommended default per language with a one-line reason, not a list of 25 |
| Very small daily targets | Default goal of one page or five verses, not a juz |
| Zero interruption | No ads, no upsell modals inside the reader |
| Encouragement, never judgement | Return copy reads Welcome back, never You broke your streak |
| Performance on mid-range Android | 60fps mushaf scroll on 4GB RAM devices, install under 60MB |
| Storage transparency | Show download size before download, offer a 64kbps standard tier |
| Asr that reaches her at work | Pre-prayer reminder with a silent or vibrate option, reliably delivered |

### Opportunities

1. **The gentle ramp.** No competitor has a genuine beginner mode. A reading experience that starts with short surahs, transliteration, and word-level meaning, then progressively reduces support as fluency improves, would be a category first.
2. **Curated translation defaults.** Replace the intimidating list with one recommended translation per language and a plain explanation. Advanced users can still change it.
3. **Progress that is not volume.** Show her that her Arabic decoding speed is improving, not just page counts. This reframes success away from quantity.
4. **Private practice.** A reading-aloud mode that no one sees and nothing is scored. Her shame is the primary barrier; privacy is the unlock.
5. **Light-touch Asr rescue.** A pre-prayer reminder configured during onboarding, without her having to find it in settings.

### Design decision rule

> If a feature requires Arabic fluency, configuration, or a fast device, it must degrade gracefully for Sara. If copy could make her feel judged, rewrite it.

---

## Persona 2 - Ibrahim Toure, the Student of Knowledge

**Secondary. Confidence: medium-high.**

| Attribute | Detail |
| --- | --- |
| Age | 27 |
| Location | Cairo, Egypt (from Lyon, France) |
| Occupation | Full-time student, second year at a traditional institute |
| Arabic ability | Strong classical reading, intermediate speaking |
| Devices | iPad Pro with Apple Pencil, iPhone 13, MacBook |
| Connectivity | Reliable Wi-Fi at the institute, patchy at home |
| Current apps | Ayah, Quran Majeed, Maktabah Shamilah, Notion, PDF readers |

### Context

Ibrahim studies fiqh, usul, and tafsir formally. He is the most demanding user in the set and the most likely to detect and publicly report a content error. He is also disproportionately influential: his peers and students ask him which app to use, so his approval propagates.

### Goals

1. Cross-reference multiple tafsir works on a single verse quickly.
2. Trace a word across the whole Qur'an by root to study usage.
3. Keep structured, citable notes tied to specific verses.
4. Verify the provenance of every text he reads.
5. Move seamlessly between phone, tablet, and desktop while studying.

### Frustrations

- Tafsir in apps is shallow, abridged without disclosure, or absent in his languages.
- No app tells him which edition or manuscript a text came from.
- Notes are trapped in the app with no export, so he keeps everything in Notion instead and loses verse linkage.
- Search is diacritic-sensitive or too primitive for morphological queries.
- Sectarian editorialising presented as neutral commentary.
- Copy and citation formatting is poor, so quoting into an essay is manual work.
- Tablet layouts are stretched phone layouts.

### Daily habits

| Time | Behaviour |
| --- | --- |
| 04:40 | Fajr at the mosque, followed by a recitation circle |
| 07:00 | Breakfast, light reading |
| 08:30 to 13:00 | Classes, taking notes on iPad |
| 14:00 to 16:00 | Independent study, deep tafsir cross-referencing |
| 17:00 | Teaching a beginners class twice a week |
| 20:00 to 23:00 | Writing, essay work, memorisation review |

His heaviest usage is a two-hour desk session on a tablet, not micro-sessions.

### Technical skills

High. Comfortable with markdown, reference managers, cloud sync, and keyboard shortcuts. Will read documentation. Will file a precise bug report with steps to reproduce. Will notice and object to a wrong hamza.

### Needs

| Need | Product implication |
| --- | --- |
| Deep, unabridged tafsir | Ibn Kathir, Jalalayn, Sa'di, Ma'ariful Qur'an, with edition disclosed |
| Provenance on everything | Visible source, translator, edition, and any abridgement flagged |
| Root and morphology search | Tap a word for root, grammar, and all occurrences |
| Diacritic-insensitive Arabic search | Sub-300ms local results |
| Notes that escape | Export to markdown with verse references intact |
| Citation-ready copy | Copy with surah, verse, translation, and translator attribution |
| Real tablet layout | Two-page spread, split view of text and tafsir, Pencil annotation |
| No silent madhhab defaults | Juristic differences exposed as settings, never imposed quietly |

### Opportunities

1. **Provenance as a feature.** No competitor discloses editions. Publishing the exact source of every text, plus checksum verification, converts scholarly rigour into a visible reason to trust the product. Ibrahim becomes an advocate.
2. **The study desk.** A genuine tablet-first layout with text, translation, tafsir, and notes in one workspace is unclaimed territory. Ayah is beautiful but phone-shaped; Quran Majeed is dense but dated.
3. **Export as retention, not leakage.** Letting notes leave increases trust and adoption. Users who can leave are more willing to commit.
4. **A content error channel.** Give him a first-class in-app reporting path routed to the review board with a 48-hour response commitment. He will find errors regardless; better that he reports them to us than to Twitter.
5. **Teacher bridge.** He teaches a beginners class. He is the natural early adopter of the Phase 5 teacher tooling.

### Design decision rule

> Ibrahim never sees an unsourced claim. If we cannot cite it, we do not ship it. Depth may be hidden behind progressive disclosure, but it must exist.

---

## Persona 3 - Hafiz Bilal Ahmed, the Hafiz

**Primary. This persona owns the product differentiator. Confidence: high.**

| Attribute | Detail |
| --- | --- |
| Age | 19 |
| Location | Karachi, Pakistan |
| Occupation | Advanced madrasa student, teaches younger pupils part-time |
| Memorisation state | 22 juz memorised, completing the remaining 8 |
| Arabic ability | Excellent recitation and tajweed; moderate comprehension |
| Devices | Xiaomi Redmi Note (mid-range Android, 4GB RAM) |
| Connectivity | Intermittent Wi-Fi, limited mobile data, frequent load-shedding |
| Current apps | Quran Majeed for repeat controls, plus a paper notebook |

### Context

Bilal's real problem is not memorising new material, it is preventing what he already knows from decaying. He tracks revision in a paper notebook because no app models it properly. His teacher tests him weekly, and he can feel which juz are weakening but cannot systematically identify which verses.

He memorises by page position. If a page break differs from his printed mushaf, his recall breaks. This makes mushaf fidelity a functional requirement for him, not an aesthetic one.

### Goals

1. Complete his hifz without losing earlier juz.
2. Know each morning exactly what to revise, without deciding.
3. Identify the specific verses where he consistently stumbles.
4. Pass his weekly teacher test with measurably improving accuracy.
5. Eventually teach with the same tooling.

### Frustrations

- Setting up a repeat loop takes many taps, every single time.
- No app schedules revision; he must decide, and he chooses badly under pressure.
- Nothing tracks which specific verses are weak, only broad completion.
- Audio downloads fail on weak connections and do not resume.
- Streak or progress data lost is devastating: months of records gone.
- Page breaks that do not match his printed mushaf break his positional recall.
- Apps assume connectivity; his electricity and Wi-Fi are both unreliable.
- Habit apps count pages read, which is irrelevant to memorisation quality.

### Daily habits

| Time | Segment | Behaviour |
| --- | --- | --- |
| 04:30 | Fajr | Mosque, then recitation |
| 05:30 to 07:30 | Sabaq | New memorisation, roughly 15 to 20 lines |
| 08:00 to 10:00 | Sabqi | Recent material, last 7 days |
| 10:00 to 12:00 | Classes | Tajweed and Arabic instruction |
| 14:00 to 16:00 | Manzil | Long-term revision, one juz cycled |
| 16:30 | Teaching | Younger pupils, twice weekly |
| 20:00 to 22:00 | Consolidation | Repeat weak passages, teacher test prep |

He is in the app four to six times per day, in long sessions, mostly offline.

### Technical skills

Medium. Confident with the apps he uses daily but not exploratory. Will not discover a buried feature. Cares intensely about reliability and battery. Suspicious of features that require an account, until sync proves valuable.

### Needs

| Need | Product implication |
| --- | --- |
| Automatic revision scheduling | Spaced repetition producing a daily queue with no decisions required |
| Native hifz vocabulary | Sabaq, sabqi, manzil as first-class concepts, not generic decks |
| One-tap loop | Repeat range, count, and pause as a saved preset, not a rebuild |
| Progressive hiding | Full text, then first word, then hidden, per verse |
| Per-verse mastery data | New, learning, review, mastered, weak, plus a weakness report |
| Absolute offline capability | Full hifz functionality with no network, syncing later |
| Zero data loss | Local-first writes, additive attempt logs, tombstone deletes |
| Page-perfect mushaf | 604 pages verified against the printed Madani edition |
| Resumable downloads | Integrity-checked, auto-resuming on reconnect |
| Teacher export | PDF or shareable progress report for his weekly test |

### Opportunities

1. **The single biggest unclaimed territory in the category.** Quran Majeed offers manual repeat controls, Quranly offers streaks, Tarteel offers AI mistake detection at a premium. Nobody offers intelligent scheduling. Building this well makes Quran One irreplaceable.
2. **Vocabulary as credibility.** Using sabaq, sabqi, and manzil signals to every madrasa student that the app was built by people who understand the discipline. It is a cheap, powerful trust signal that no Western-built competitor has made.
3. **Switching cost as a moat.** A user with two years of spaced-repetition history and per-verse mastery data will not migrate. This is the strongest retention mechanism available to the product.
4. **The weakness report.** Telling him which specific verses are decaying solves a problem he currently addresses with a paper notebook and intuition. High perceived value, purely computational cost.
5. **Teacher pathway.** He already teaches. He is the organic bridge into the institutional market, and he brings his pupils with him.
6. **Low-end Android as a market, not a constraint.** Tier 2 markets contain the majority of serious hifz students and are the least well served on performance and offline reliability.

### Design decision rule

> Bilal's data is sacred and his network is unreliable. Every hifz interaction must work offline, write locally first, and never lose a record. Never make him decide what to revise.

---

## Persona 4 - Amina Hassan, the Busy Professional

**Primary. Confidence: high.**

| Attribute | Detail |
| --- | --- |
| Age | 38 |
| Location | Dubai, UAE |
| Occupation | Finance director, frequent regional travel |
| Arabic ability | Fluent recitation, moderate comprehension |
| Devices | iPhone 15 Pro, Apple Watch, work laptop, iPad occasionally |
| Connectivity | Excellent, but often in airports and on flights |
| Current apps | Pillars for prayer, Ayah for reading, calendar-driven life |

### Context

Amina's constraint is not motivation or ability, it is fragmented time and constant time-zone change. She travels twice monthly across the Gulf and to Europe. Her app usage is high-frequency and very short: she needs answers in under five seconds.

She is the highest-ARPU persona and the most likely to buy a lifetime tier without hesitation if the product respects her.

### Goals

1. Never miss a prayer window, in any city, without configuring anything.
2. Read a little every day despite an unpredictable schedule.
3. Keep her spiritual practice private from colleagues.
4. Resume instantly wherever she left off, on whichever device is in her hand.
5. Feel that her practice is consistent despite her travel.

### Frustrations

- Prayer times drift or fail to update when she lands in a new time zone.
- Athan fires audibly during meetings; she has been embarrassed.
- Calculation-method settings are jargon-heavy and buried, so she does not trust them.
- Apps take too long to open and require too many taps for a five-second need.
- Progress and bookmarks do not sync between phone, watch, and iPad.
- Notifications that guilt her about missed days.
- Reading plans assume a predictable schedule she does not have.

### Daily habits

| Time | Behaviour |
| --- | --- |
| 05:10 | Fajr, then gym |
| 07:30 | Commute, sometimes listens to recitation |
| 09:00 to 18:00 | Meetings, checks prayer widget on watch between them |
| 12:30 | Dhuhr, prays in a quiet room, needs silent reminder |
| 15:45 | Asr, often mid-meeting, needs a discreet nudge |
| 21:00 | Family time |
| 22:30 | 10 minutes reading before sleep, her only reliable window |

Twenty to thirty short interactions per day plus one short reading session. Watch glances outnumber phone opens.

### Technical skills

High but impatient. Uses widgets, watch complications, and shortcuts extensively. Expects the product to be correct by default. Will pay to avoid friction. Will churn silently rather than complain.

### Needs

| Need | Product implication |
| --- | --- |
| Automatic travel handling | Time-zone and location change detected, with a non-blocking confirmation |
| Discreet notifications | Per-prayer silent, vibrate, or audible; quiet hours; respects focus modes |
| Correct defaults | Calculation method inferred per region with plain-language explanation |
| Glanceable surfaces | Widgets and watch complication showing next prayer and countdown |
| Instant resume | Under two seconds to interactive, landing exactly where she stopped |
| Flexible plans | Reading targets that absorb missed days without penalty or reset |
| True cross-device sync | Phone, watch, iPad, web, delta-synced |
| Privacy at work | Nothing on the lock screen that reveals religious practice unless she opts in |

### Opportunities

1. **Travel intelligence.** Detect the time-zone change, recalculate, and confirm without blocking. This is a top complaint against incumbents and is straightforward to solve well.
2. **Watch-first prayer.** Pillars ships strong widgets but limited watch depth. Owning the glance is owning Amina's daily loop at near-zero engagement cost.
3. **Discretion as a premium feature.** Silent per-prayer nudges, no religious content on the lock screen by default. No competitor treats workplace discretion as a design concern.
4. **Flexible plan mechanics.** A plan that redistributes missed days instead of breaking is directly aligned with the no-guilt doctrine and fits her life.
5. **Lifetime pricing.** She is the buyer least sensitive to price and most sensitive to friction. Make the lifetime tier easy to find and trivially quick to purchase.

### Design decision rule

> Amina gets her answer in one glance and zero configuration. If a prayer feature needs setup to be correct, the default was wrong.

---

## Persona 5 - Khadija Osman, the Parent

**Secondary. Confidence: medium.**

| Attribute | Detail |
| --- | --- |
| Age | 35 |
| Location | Minneapolis, USA |
| Occupation | Part-time nurse, mother of three (ages 5, 8, 12) |
| Background | Somali-American, second generation |
| Arabic ability | Reads slowly, limited comprehension |
| Devices | iPhone 12, shared family iPad, Chromebook |
| Connectivity | Home Wi-Fi, unlimited data |
| Current apps | Muslim Pro, YouTube for children's Islamic content, a kids' Qur'an app |

### Context

Khadija's primary goal is not her own practice, it is her children's. She is the household's religious project manager: she decides which apps the children use, she supervises memorisation homework she is not fully confident correcting, and she is deeply anxious about screen content.

She is a distribution multiplier. If she trusts Quran One, she installs it on four devices and recommends it at the mosque.

### Goals

1. Help her children build a genuine relationship with the Qur'an.
2. Supervise her 8-year-old's memorisation homework without needing to be a hafiza herself.
3. Give her children screen time she does not feel guilty about.
4. Maintain her own modest daily practice in the gaps.
5. Establish family routines around prayer.

### Frustrations

- Islamic kids' content on YouTube is unpredictable and ad-laden; she does not trust autoplay.
- She cannot verify whether her child is reciting correctly.
- No visibility into what her children actually did in an app.
- Kids' apps are either babyish or too advanced, and gamification tips into pure distraction.
- She has no time for her own reading; her sessions are three minutes, interrupted.
- Managing several apps across several devices and children is exhausting.
- Fear of a child encountering inappropriate advertising inside a religious app.

### Daily habits

| Time | Behaviour |
| --- | --- |
| 05:30 | Fajr, then prepares the household |
| 07:00 to 08:30 | School run chaos |
| 09:00 to 15:00 | Shifts three days a week |
| 16:00 to 18:00 | Homework supervision, including Qur'an memorisation |
| 18:30 | Family dinner, sometimes a short Qur'an moment together |
| 20:00 | Children's bedtime routine, dua and short surahs |
| 21:30 | Her own reading, when energy permits, often skipped |

Her sessions are short and frequently interrupted. The children's sessions are the ones she actually cares about.

### Technical skills

Medium. Manages family devices, screen-time controls, and school portals competently. Will configure parental settings once if the flow is clear. Will not maintain complex configuration.

### Needs

| Need | Product implication |
| --- | --- |
| Verified safe content | Zero ads, no external links, no autoplay into unknown content |
| Child-appropriate mode | Simplified interface, age-appropriate scope, restricted navigation |
| Parent visibility | A simple weekly view of what each child did |
| Recitation reassurance | Something that helps her judge correctness without expertise |
| Family setup | Multiple child profiles on shared devices, managed from one place |
| Micro-sessions for herself | Value in three minutes: one verse, one dua, a short listen |
| Prayer routines for the household | Shared prayer times and gentle family reminders |
| Cost control | One family price rather than per-child subscriptions |

### Opportunities

1. **Trusted family tier.** Verified content, zero ads, and a parent dashboard directly answers her deepest anxiety. NOOR addresses children specifically; no unified family product exists at quality.
2. **Supervision without expertise.** Even simple support, showing her the correct recitation to compare against, plus a checklist for her child's assigned range, removes her confidence gap.
3. **Micro-session design.** A three-minute mode with one verse, its meaning, and a dua respects her real constraint. Most apps design for a 15-minute session she never has.
4. **Family as growth loop.** One trusted parent installs on four devices and evangelises at the mosque. Family pricing converts a single decision into multiple users.
5. **Ramadan family routines.** Shared countdowns and simple household plans map onto how her family already behaves seasonally.

### Design decision rule

> Khadija must be able to hand a device to a child without checking what is on screen. Any content, ad, or link that could reach a child without her consent is a defect.

---

## Persona 6 - Zayd Osman, the Child

**Tertiary. Roadmap phase 5. Confidence: low-medium, needs direct research with children.**

| Attribute | Detail |
| --- | --- |
| Age | 8 |
| Location | Minneapolis, USA (Khadija's son) |
| Occupation | Third grade; weekend Islamic school |
| Arabic ability | Learning letters and short surahs by ear |
| Devices | Shared family iPad, limited screen time, no personal phone |
| Supervision | Parent-managed profile and time limits |
| Current apps | Kids' Qur'an app, educational games, YouTube Kids |

### Context

Zayd is memorising short surahs for weekend school. He learns primarily by ear and imitation and cannot yet read Arabic independently. His attention span for a focused task is roughly 8 to 12 minutes. He is not the buyer, and he is not the decision-maker, but if he refuses to use the app the parent uninstalls it.

Special care applies: he is a minor, so data collection, social features, and any form of competitive pressure require unusually conservative design.

### Goals

1. Learn his assigned surah well enough to recite it in class without embarrassment.
2. Feel capable and successful rather than corrected.
3. Have fun while doing it.
4. Earn his parent's visible approval.

### Frustrations

- Adult interfaces are dense and unreadable for him.
- Being told he is wrong repeatedly makes him refuse to continue.
- Text-based instructions do not work; he needs audio and images.
- Sessions designed for 20 minutes exceed his attention span.
- Losing progress upsets him disproportionately.
- Competitive leaderboards make him anxious rather than motivated.

### Daily habits

| Time | Behaviour |
| --- | --- |
| 07:00 | School preparation |
| 08:30 to 15:00 | School |
| 16:00 to 17:00 | Homework, including Qur'an practice with a parent nearby |
| 17:00 to 18:00 | Play, some screen time |
| 20:00 | Bedtime, short surahs and dua with a parent |
| Weekend | Islamic school, assigned memorisation reviewed |

One supervised 10-minute session on weekdays, longer on weekends.

### Technical skills

Digitally native but pre-literate in Arabic and only partly literate in English. Navigates by icon, colour, and audio. Cannot type reliably. Cannot read settings. Everything must be tappable, spoken, and visual.

### Needs

| Need | Product implication |
| --- | --- |
| Audio-first everything | Every instruction spoken; no reliance on reading |
| Very short sessions | 5 to 10 minute units with a clear, celebrated end |
| Listen-and-repeat loop | Hear the verse, repeat it, hear it again; imitation not instruction |
| Encouragement-only feedback | Never a red cross; guide toward correct without declaring failure |
| Visible, tangible progress | Simple visual completion, no competitive ranking |
| No social exposure | No leaderboards, no public profiles, no friend comparisons |
| Absolute safety | No ads, no links, no chat, no external content whatsoever |
| Minimal data | Collect the bare minimum; parental consent; no behavioural profiling |

### Opportunities

1. **Audio-first memorisation for pre-readers.** Children memorise by ear. A listen, repeat, and confirm loop needs no reading ability at all and fits how weekend schools actually teach.
2. **Encouragement-only feedback design.** If speech feedback ships for children, it must guide, never fail. Getting this wrong with a religious text and a child is a serious trust event; the conservative design is also the correct one.
3. **Parent-visible progress as the reward.** His strongest motivator is parental approval. Surfacing his work to his parent is more effective than gamified points and carries none of the anxiety.
4. **Weekend-school alignment.** Assigned-surah structures map directly onto real homework, making the app immediately useful rather than supplementary.
5. **Long-horizon retention.** A child who learns on Quran One and grows into the adult product is the highest lifetime-value user in the entire set. This justifies patient investment even at low near-term revenue.

### Design decision rule

> Zayd cannot read, cannot type, and must never be told he failed. If a child-facing surface requires literacy or delivers negative feedback, redesign it. Collect the minimum data legally and ethically possible.

---

## Persona 7 - Yusuf Chen, the New Muslim

**Secondary. Confidence: high.**

| Attribute | Detail |
| --- | --- |
| Age | 31 |
| Location | Toronto, Canada |
| Occupation | Software engineer |
| Background | Muslim for 14 months; no Muslim family; converted after independent study |
| Arabic ability | Learning the alphabet; cannot read fluently; no comprehension |
| Devices | Pixel 8, desktop Chrome, iPad, Apple Watch |
| Connectivity | Excellent everywhere |
| Current apps | Quran.com, Ayah, Athan, several study apps, Anki |

### Context

Yusuf has no inherited scaffolding. He does not know the sequence in which things are normally learned, cannot ask family, and is acutely aware of the risk of learning from a bad source. He compensates by over-researching and by building his own systems, including Anki decks for Arabic vocabulary.

He is highly motivated, technically expert, and prepared to pay for quality. He is also fragile in a specific way: he fears doing it wrong more than he fears difficulty.

### Goals

1. Learn to pray correctly and with confidence.
2. Learn to read Arabic, then to understand it.
3. Memorise the short surahs needed for salah.
4. Understand what he recites, word by word.
5. Verify that everything he learns comes from a legitimate source.
6. Know the correct order in which to learn things.

### Frustrations

- Every app assumes inherited knowledge, including basic vocabulary and sequence.
- No app tells him what to learn first, second, and third.
- Cannot assess which translations, reciters, or opinions are trustworthy.
- Transliteration schemes differ between and within apps, so pronunciation is inconsistent.
- Practical salah mechanics are absent: what to say, when, and in which posture.
- Fear of embarrassment at the mosque leads him to practise privately and anxiously.
- Content that assumes a madhhab without naming it leaves him unable to reason about differences.

### Daily habits

| Time | Behaviour |
| --- | --- |
| 05:30 | Fajr, still checks a guide for the sequence |
| 06:00 | 20 minutes Arabic study, Anki reviews |
| 09:00 to 18:00 | Work; prays Dhuhr and Asr in a quiet room, watch reminders |
| 19:00 | Gym, listens to recitation and lectures |
| 21:00 to 22:30 | Deep study: one verse, multiple translations, tafsir, word breakdown |
| Friday | Jumu'ah, still nervous about procedure |

One long study session daily plus short prayer interactions. He is the highest-intent learner in the set.

### Technical skills

Very high. Builds his own tooling, uses spaced repetition already, will use a web app and keyboard shortcuts, will read documentation thoroughly, and will notice inconsistency immediately. Will also evangelise loudly if impressed.

### Needs

| Need | Product implication |
| --- | --- |
| A guided sequence | An explicit learning path: what to learn now, next, and after |
| Practical salah instruction | Step-by-step mechanics with audio, transliteration, and translation |
| One consistent transliteration | Documented scheme applied everywhere without exception |
| Word-by-word comprehension | Tap for root, grammar, and occurrences |
| Source transparency | Which scholars, which translation, which madhhab, clearly labelled |
| Slow, loopable audio | 0.5x to 1.0x with pitch preservation and configurable repeats |
| Private practice | Rehearse without observation or scoring |
| Spaced repetition for vocabulary and short surahs | He already uses Anki; meet him where he is |
| Web parity | He studies at a desktop |

### Opportunities

1. **The guided path is the largest revert-facing gap in the category.** Nobody sequences learning. A structured path from prayer mechanics to short surahs to reading fluency to comprehension would be a defining feature, and it serves Sara as well.
2. **Salah as a first-class learning module.** Practical prayer instruction with audio and posture guidance is absent from every app analysed, despite being the single most urgent need of every new Muslim.
3. **Transliteration consistency as a differentiator.** A published, documented scheme applied without exception solves a frustration that affects all learner personas and costs nothing but discipline.
4. **Reuse the hifz engine.** The spaced-repetition system built for Bilal serves Yusuf directly for vocabulary and short surahs. One engine, two high-value personas.
5. **Reverts are disproportionately influential advocates.** Technically sophisticated, active in online communities, and vocal. Serving Yusuf well produces organic advocacy far beyond his segment size.
6. **Willingness to pay is high.** He values quality, distrusts advertising, and already pays for software tools. Prime lifetime-tier candidate.

### Design decision rule

> Yusuf must never have to already know something to learn it. Every religious instruction states its source. Never assume inherited context.

---

## Persona 8 - Shaykh Musa Diallo, the Imam

**Tertiary for v1, strategic for phase 5. Confidence: medium.**

| Attribute | Detail |
| --- | --- |
| Age | 52 |
| Location | Paris, France |
| Role | Imam of a mid-size mosque, roughly 400 regular attendees; teaches 30 students |
| Arabic ability | Native-level classical Arabic; hafiz |
| Devices | Android tablet, older iPhone, laptop |
| Connectivity | Mosque Wi-Fi, home broadband |
| Current apps | Quran Majeed, WhatsApp for community coordination, printed references |

### Context

Shaykh Musa is not a heavy app user, but he is the highest-leverage persona in the set. A recommendation from him converts dozens of households at once. He is also the most conservative adopter: he will not endorse a product he has not scrutinised, and his reputation is at stake if he recommends something with a content error.

His practical burdens are administrative: coordinating congregation prayer times, preparing khutbah references, assigning and tracking student memorisation, and answering the same questions repeatedly.

### Goals

1. Teach effectively and track his students' memorisation reliably.
2. Prepare khutbah and lessons quickly, with accurate citations.
3. Publish his mosque's congregation prayer times so the community stops phoning.
4. Recommend one trustworthy app instead of fielding the question weekly.
5. Protect his community from unreliable religious content.

### Frustrations

- Tracks 30 students on paper; nothing scales.
- Apps show calculated prayer times that differ from his mosque's actual iqamah, confusing his congregation.
- Cannot verify an app's content provenance easily, so he hesitates to endorse anything.
- No teacher tooling exists: cannot assign ranges or review student progress.
- Preparing citations means cross-referencing physical books.
- Community members bring him screenshots of dubious content from apps and social media.
- Interfaces assume younger, more device-fluent users.

### Daily habits

| Time | Behaviour |
| --- | --- |
| 04:30 | Leads Fajr at the mosque |
| 06:00 to 08:00 | Personal recitation and study |
| 09:00 to 12:00 | Administration, community matters, counselling |
| 13:00 | Leads Dhuhr |
| 15:00 to 17:00 | Teaching, hears student recitation individually |
| 18:00 to 21:00 | Leads Maghrib and Isha, evening classes |
| Thursday | Khutbah preparation |
| Friday | Jumu'ah |

He is in the mosque, not on a phone. Usage is deliberate and desk-based, mostly on a tablet.

### Technical skills

Medium-low to medium. Competent with WhatsApp, email, and basic apps. Prefers larger text and simple flows. Will not troubleshoot. Will delegate technical setup to a younger volunteer if the value is clear.

### Needs

| Need | Product implication |
| --- | --- |
| Student roster and assignment | Assign verse ranges, see progress per student |
| Progress review | Which students are behind, which verses are weak, without asking each one |
| Mosque prayer times publishing | Post actual iqamah times that override calculated times for his community |
| Verifiable content provenance | Clear sources so he can endorse the app in good conscience |
| Fast citation lookup | Search across Qur'an and tafsir with reference-ready copy |
| Large text and simple navigation | Accessibility for a 52-year-old, low-patience user |
| Institutional pricing | One mosque or school licence, not 30 individual subscriptions |
| No sectarian defaults | Juristic settings exposed, never silently imposed |

### Opportunities

1. **Highest-leverage acquisition channel in the product.** One imam endorsement can convert hundreds of households at near-zero cost. Institutional features pay for themselves through distribution, before any licence revenue.
2. **Mosque iqamah times.** Pillars has announced movement here; it remains largely unbuilt. Publishing real congregation times solves a genuine community problem and creates a local network effect that is very hard for a competitor to dislodge.
3. **Teacher dashboard on top of the hifz engine.** The per-verse mastery data built for Bilal is exactly what Musa needs to supervise 30 students. One data model, two products.
4. **Provenance as endorsement enabler.** He cannot recommend what he cannot verify. Published sources and a named scholarly review board convert his caution from a barrier into an advantage over competitors.
5. **Institutional market.** Madrasas, mosques, and Islamic schools represent recurring, low-churn revenue that is independent of consumer subscription behaviour.
6. **Content authority loop.** Imams like Musa are the natural review board and error-reporting network. Involving them improves quality and creates advocacy simultaneously.

### Design decision rule

> Musa must be able to verify every claim before he stakes his reputation on it. Teacher tooling must work for a 52-year-old on a tablet who will not troubleshoot. Never override a mosque's actual times with a calculation.

---

## Cross-persona synthesis

### Shared needs (build once, serve everyone)

| Need | Personas served | Notes |
| --- | --- | --- |
| Zero advertising | All 8 | The universal requirement; also a child-safety requirement |
| Offline capability | All 8, critically Bilal | Worship must not depend on connectivity |
| Encouragement without guilt | All 8, critically Sara and Zayd | A copy doctrine, enforced in review |
| Never lose user data | All 8, critically Bilal | Local-first writes, additive logs, tombstones |
| Source transparency | All 8, critically Ibrahim and Musa | Visible attribution on every text |
| Performance on mid-range Android | Sara, Bilal, Khadija | Where the volume market lives |
| Consistent transliteration | Sara, Yusuf, Zayd, Khadija | One documented scheme, no exceptions |
| Cross-device sync | Amina, Ibrahim, Yusuf, Khadija | Delta sync with real web parity |

### Conflicts and how they resolve

| Conflict | Resolution |
| --- | --- |
| Sara needs simplicity; Ibrahim needs depth | Progressive disclosure. Depth exists but is never the default surface. Onboarding sets the starting level. |
| Amina needs 5-second interactions; Bilal needs 2-hour sessions | Separate entry points from one home screen: glanceable prayer and continue-reading for Amina, a dedicated hifz session mode for Bilal. |
| Quranly-style streaks drive retention; guilt harms Sara and Zayd | Streaks encourage only. Missing a day produces Welcome back. Pause states for travel, illness, and menstruation. Never lose streak history. |
| Zayd needs gamification; reverence forbids trivialising worship | Celebrate effort and completion, never the sacred text itself. No points attached to verses; no competitive ranking anywhere. |
| Musa needs mosque iqamah times; Amina needs calculated times while travelling | Calculated times are the default; mosque times are an opt-in community layer that never silently overrides. |
| Khadija needs parent visibility; older children need privacy | Age-banded: full visibility under 10, summary only for 10 to 13, self-managed at 14+ with parental consent. |

### Persona-to-feature map

| Feature area | Primary persona | Also serves |
| --- | --- | --- |
| Mushaf reader and typography | Sara | All |
| Beginner mode and guided path | Sara | Yusuf, Zayd, Khadija |
| Word-by-word and morphology | Yusuf | Ibrahim, Sara |
| Tafsir library and provenance | Ibrahim | Musa, Yusuf |
| Hifz spaced-repetition engine | Bilal | Yusuf, Zayd, Musa |
| Prayer times, Athan, travel handling | Amina | All |
| Widgets and watch | Amina | Khadija |
| Family profiles and parent dashboard | Khadija | Zayd |
| Audio-first child mode | Zayd | Khadija |
| Salah instruction module | Yusuf | Sara, Zayd |
| Teacher dashboard and rosters | Musa | Bilal, Ibrahim |
| Mosque iqamah times | Musa | Amina, Khadija |

### Research gaps to close before Phase 1 exit

1. **Children require direct research.** Zayd is the lowest-confidence persona. Never design for children from adult assumptions; run supervised sessions with parental consent.
2. **Validate the hifz workflow with real madrasa students and teachers.** The sabaq, sabqi, manzil model is drawn from documented practice, but the exact rhythms vary by institution and region. Get this wrong and the differentiator fails.
3. **Test the beginner shame hypothesis.** Sara's core barrier is assumed to be embarrassment rather than motivation. If that is wrong, the entire beginner ramp is mis-designed.
4. **Measure real Athan failure rates** across the OEM matrix in the field, not only in the lab.
5. **Interview imams and teachers on endorsement criteria.** What specifically would make Musa recommend an app from the minbar?
6. **Validate willingness to pay** in Tier 2 markets, where Bilal lives and where the hifz differentiator matters most.

---

## Appendix - Persona summary card

| Persona | Age | Role | Core need | Biggest risk if ignored |
| --- | --- | --- | --- | --- |
| Sara | 24 | Beginner Muslim | A judgement-free ramp into reading | Churns silently, feeling inadequate |
| Ibrahim | 27 | Student of Knowledge | Depth with verifiable provenance | Publicly reports a content error |
| Bilal | 19 | Hafiz | Automatic revision scheduling, offline | We forfeit our only real moat |
| Amina | 38 | Busy Professional | Correct by default, glanceable | Loses highest-ARPU segment |
| Khadija | 35 | Parent | Verified-safe content, parent visibility | Loses a 4-device household and mosque advocacy |
| Zayd | 8 | Child | Audio-first, encouragement-only | Refuses the app; parent uninstalls |
| Yusuf | 31 | New Muslim | A sequenced learning path | Loses the loudest advocate segment |
| Musa | 52 | Imam | Verifiable content, teacher tooling | Forfeits community-scale distribution |
