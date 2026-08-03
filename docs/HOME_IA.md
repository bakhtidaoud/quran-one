# Home Screen Information Architecture

Status: authoritative for the Home surface.
Related: `docs/NAVIGATION.md`, `docs/ACCESSIBILITY.md`,
`docs/DESIGN_SYSTEM.md`.
Implemented by `lib/features/home/presentation/`.

---

## 1. The governing measurement

Home is opened roughly eight times a day for about four seconds. In the
large majority of those openings the user is answering one question:
**how long until the next prayer.**

Every decision below follows from that. Content that competes with that
answer does not earn its place merely by being religiously valuable; it
has to be more valuable than four seconds of the user's attention at the
moment they opened the app.

## 2. Tiers

| Tier | Rule | Position | Members |
| --- | --- | --- | --- |
| 1 | Unconditional | Fixed, above the fold | Hijri header, prayer card, continue reading |
| 2 | Conditional on having something to say | Fixed relative order | Review due, wird, achievement |
| 3 | Daily, not urgent | Below the fold | Hadith, dua |

Sections carry a numeric `rank` and the queue is sorted, not appended.
A new section placed wrongly is then a rank error a test can catch,
rather than a layout error nobody notices.

### 2.1 Card priority table

| Rank | Section | Why it sits there |
| --- | --- | --- |
| 100 | Hijri header | Hijri primary, Gregorian secondary. The Gregorian date is already in the status bar; the Hijri date is the one nobody can recall |
| 110 | Prayer card | The reason the app was opened |
| 120 | Continue reading | Highest value after prayer. Shows the verse, not a percentage |
| 200 | Review due | Time sensitive: spaced repetition decays |
| 210 | Wird | A commitment the user set, not one we invented |
| 220 | Achievement | Once, on the day earned, dismissible |
| 300 | Hadith | Daily, no deadline |
| 310 | Dua | Daily, no deadline |

## 3. Visual hierarchy

Four levels, expressed through weight and fill rather than colour
variety.

1. **The countdown** is the only `displaySmall` on the screen.
2. **The prayer card** is the only filled container. Everything else is
   `surface` with a hairline `outlineVariant`. No elevation anywhere:
   cards that float make a calm screen busy.
3. **Tier 2 rows** are 56dp, `titleSmall`, single line.
4. **Tier 3** uses section headers with `header: true` semantics so a
   screen reader can jump past tier 1.

AMOLED uses a *dimmer* prayer container (`#1A3A30`) than dark
(`#2B5C4C`). A bright fill on pure black is a glare source at Fajr,
which is exactly when this screen is used in the dark.

## 4. Progressive disclosure

Home is a set of doorways. Nothing on it is a destination.

| Element | Reveals |
| --- | --- |
| Prayer card | Prayer tab, today's full timetable |
| Continue reading | Reader at the stored position |
| Review due | Review session |
| Wird | Reader, scoped to the wird range |
| Hadith / dua | Full text, source, sharing |

Quick actions (qibla, tasbih, search, azkar) live in the app bar
overflow, not as a tile grid. A 2x3 grid of coloured icons is where a
dashboard becomes a launcher.

**There is no customisation.** Reorderable cards sound generous and
produce a support surface, a sync entity, and a screen that is worse for
the median user because they never open the editor.

## 5. Empty states

The rule is inverted from the usual practice: **an empty state is a
design failure unless the emptiness is actionable.**

| Condition | Treatment |
| --- | --- |
| No cards due | Render nothing. A row saying "no cards due" is pixels reporting the absence of work |
| No wird configured | Render nothing. Not everyone keeps one, and Home is not the place to sell the idea |
| No achievement today | Render nothing |
| Hadith failed to load | Render nothing. A missing daily hadith does not warrant an apology |
| No reading position | The card does not disappear. It offers Al-Fatiha and relabels to "Start reading" |
| No coordinates ever stored | The one designed empty state: `QLocationNeededCard`, which states on the card itself that times are computed on device and the location is never sent |

## 6. Loading states

**Home never shows a full screen spinner.** Every value it needs is
already on device or computable on device from stored coordinates. A
spinner here means something has been architected wrong.

- Tier 1 renders its skeleton at the exact height of the real content.
  A skeleton of a different size makes the screen jump on resolve,
  which reads as slower than a longer wait would have.
- The skeleton is excluded from semantics. Announcing "loading" for
  something that resolves inside the frame budget is noise.
- Tier 2 and 3 have no loading state at all: they appear when ready.

## 7. Offline states

**Offline is not an error on this screen and must not look like one.**
Prayer times, reading position, wird and due count are all local.
Nothing above the fold degrades.

The only honest signal is that sync has paused, and it is a quiet app
bar icon with a semantic label giving the pending count. No banner, no
toast, no colour change. A banner would displace the prayer card to
report a condition the user cannot act on.

An expired session behaves identically. The app stays fully usable and
the only visible change is the sync indicator.

## 8. Responsive behaviour

| Breakpoint | Layout |
| --- | --- |
| < 600 | Single column, full width, 16dp gutter |
| 600 to 899 | Single column, 560dp measure, centred, 24dp gutter |
| >= 900 | Two columns: tier 1 fixed at 420dp, tiers 2 and 3 beside it |

The binding rule: **widening the window must never promote tier 2 or 3
content above tier 1.** A tablet user asks the same question and
deserves the same answer in the same place. Extra width buys a second
column of secondary content, never a reordering.

The primary column is capped even on very wide windows. A prayer card
1200 pixels wide puts the countdown further from the prayer name than
from the edge of the screen.

## 9. RTL

All padding is directional. The Arabic prayer name leads, the Latin
transliteration follows, and that order reverses correctly because it
is a `Row` and not a hand-built string. Numerals follow the locale via
`NumeralSystem`. Prayer names are never translated in any of the twelve
locales, including inside semantic labels.

## 10. Accessibility

| Rule | Reason |
| --- | --- |
| The countdown is **not** a live region | It changes every minute. As a live region it interrupts a screen reader user continuously and they will turn the app off. Announced on focus only |
| The prayer card is one utterance | "Asr, in 1 hour 12 minutes, at 16:42. Dhuhr passed 2 hours ago." |
| Tier 2 rows are 56dp | Above the 48dp floor |
| Verse preview holds 12:1 | AAA on scripture, even in a preview |
| Reduced motion removes the digit crossfade | Decorative only |
| Type is never clamped | 200 percent scaling reflows; tier 2 rows grow |

## 11. Home screen widgets

The widget matters more than the dashboard. A user with the countdown
on their lock screen opens the app less and stays longer when they do.
Optimising Home for opens is a trap.

| Size | Content |
| --- | --- |
| Small | Next prayer and countdown. Nothing else |
| Medium | Countdown plus all five times, current one marked |
| Lock screen | Countdown, one line |

Widgets compute times on device from stored coordinates and never
fetch. A widget showing a spinner or a stale time is worse than no
widget.

## 12. Explicitly excluded

| Item | Reason |
| --- | --- |
| Weather | A location prompt, a third party API and a network dependency, in exchange for answering no religious question |
| Bookmarks, favourites | Deliberate destinations. On Home they push the prayer card down |
| Recent activity | A feed of the user's own past actions |
| Islamic calendar | Belongs beside prayer times; on Home it is a second date display |
| Premium banner | Principle P4. Home is the most visited worship surface in the app. Premium lives in Settings and appears at the point of need, which converts better anyway because the value is legible at that moment |

## 13. Open questions

1. The twenty minute post adhan hold is a guess. It should be tuned
   against real data once telemetry exists, per madhhab if necessary.
2. Two column expanded layout has not been tested with 200 percent
   text scaling.
3. The wird section assumes a single wird. Multiple concurrent awrad
   would need a different rule than "show the incomplete one".
