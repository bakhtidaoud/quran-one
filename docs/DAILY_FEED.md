# Daily Set Strategy

Status: authoritative for daily content.
Related: `docs/HOME_IA.md`, `docs/PRD.md` (principles P1 to P7).
Implemented by `lib/features/home/domain/`.

---

## 1. It is not a feed

A feed has three properties: it is infinite, it is algorithmically
ordered, and it is optimised for time spent. All three are wrong here.

An infinite scroll of religious content trains the user to consume
revelation the way they consume everything else, and the metric it
optimises - session length on the home screen - is in direct conflict
with the product's actual goal, which is that people read the Quran and
pray on time. An app that succeeds at engagement and fails at that has
failed.

So: **three items, fixed, finite, the same all day.** When the user
reaches the end there is nothing more, and the intended next action is
to leave the home screen.

| Rank | Item | Notes |
| --- | --- | --- |
| 100 | Verse of the day | With its own tafsir, collapsed |
| 110 | Hadith of the day | Sahih or hasan only |
| 120 | Dua of the day | The only contextual selection |

## 2. What was cut, and why

### Islamic Quote - refused outright

This is the most important decision in the document. Unattributed
inspirational quotation is the single largest vector for fabricated
hadith on the internet. A card that renders beautiful text over a
gradient with "Prophet Muhammad (PBUH)" as the entire attribution is a
fabrication engine with a nice font, and once it is shipped there is no
way to audit what went out.

The rule: if a statement is authentic it is a hadith and it carries a
grading. If it is a scholar's words it carries a name and a work. If it
carries neither, it does not ship. There is no third category.

### Tafsir as an independent item - merged

A commentary on a verse other than the one displayed above it is
incoherent. Tafsir is a disclosure on the verse card, collapsed by
default because a card that opens at four hundred words is a card
nobody finishes.

### Learning tip, memorization reminder, prayer reminder - relocated

None of these are content.

| Requested as feed | Actually is |
| --- | --- |
| Memorization reminder | The tier 2 review row on Home, driven by the real due count |
| Prayer reminder | A notification, plus the prayer card |
| Learning tip | Coaching, which does not belong in the same register as revelation |

Mixing coaching copy into a surface that also renders the Quran
flattens the two into one voice. That is the specific quality failure
that makes competitor home screens feel cheap.

## 3. Selection logic

Selection is a **pure function of the local date and the installed
content pack version.** No server call, no model, no request.

```
index = f(channel, poolSize, dayNumber, packVersion)
```

The implementation walks a permuted cycle using a coprime stride rather
than taking a random number modulo the pool size. Naive modulo repeats
an item roughly every forty days on a pool of a thousand, and users
notice repetition far more than they notice novelty. Walking a cycle
guarantees no item recurs until every item has been shown.

Four properties this buys that a recommender cannot:

1. **It works offline**, which is the default state of this app (P1).
2. **It is identical across the user's devices** with no sync entity.
3. **It is reproducible.** Given a date and a pack version, anyone
   reviewing a complaint can regenerate exactly what was displayed.
4. **It reveals nothing.** A server that picks your verse learns what
   you were shown.

The day turns over at the user's local midnight, not UTC. Casablanca
and Jakarta see different items for several hours, and that is correct.

## 4. Personalisation strategy

Three tiers. Tier 0 is the default and is the entire product for most
users.

| Tier | Inputs | Leaves device |
| --- | --- | --- |
| 0 `none` | Date, pack version | No |
| 1 `contextual` | Clock, Hijri date, locale | No |
| 2 `declared` | Topics the user explicitly chose, exclusion list | No |

Tier 1 is not profiling and cannot be switched off, because "show the
evening dua in the evening" is not a model of the user, it is a clock.

Tier 2 is opt-in from Settings and stored locally. It is never synced,
because a topic list is itself a statement about someone's religious
concerns.

### The line this product does not cross

**Behavioural inference is not a tier and will not be built.**

Selecting content from what someone reads, how often they pray, or
which verses they linger on means building a profile of religious
practice. Under GDPR that is Article 9 special category data. The app's
standing promise is that reading history never reaches the server, and
a recommender is the most likely component to quietly break it - not
maliciously, but because a model needs training data and someone will
propose collecting it.

This also disposes of the usual counter-argument that on-device
inference is safe. It is safer, but the moment a relevance score exists
on the device, shipping it becomes a one-line change in a future sprint
by someone who never read this document.

## 5. Curation and authenticity

| Rule | |
| --- | --- |
| Grading | Sahih or hasan only. Nothing weaker, nothing ungraded, in the pool at all |
| Provenance on the card | "Sahih al-Bukhari 6407" is content, not metadata. Never behind a tap |
| Translator named | Always, for every translated line |
| Abridgement declared | Silently shortening a scholar is a form of misquotation |
| No generated content, ever | Risk AR-7. Nothing in this pool is written by a model, including summaries |
| Scholarly sign-off | Every pool version is reviewed before publication and the reviewer is recorded in the pack manifest |

Content ships in versioned packs, so a mistake is corrected without an
app release (P7), and a revoked pack version stops being served
immediately.

## 6. Notifications

At most **one** daily content notification, opt-in, off by default,
at a time the user picks. It never fires in a prayer window.

The daily set is not a reason to interrupt somebody. If they open the
app they will see it, and if they do not, a verse they were pushed into
reading while distracted was not worth the interruption.

## 7. Metrics, and the ones we refuse

| Measured | Refused |
| --- | --- |
| Taps from verse card into the reader | Time on home screen |
| Whether the tafsir disclosure is opened | Daily feed sessions per user |
| Marks created from a daily item | Scroll depth |
| Reports of a bad or misattributed item | Any engagement target on religious content |

The success condition for this surface is that it sends people
somewhere else. A metric that rewards keeping them here would
eventually rebuild the infinite feed by increments.

## 8. Open questions

1. Pool size is unknown because no pool exists yet. Below roughly 400
   items per channel the annual repeat rate becomes noticeable.
2. Ramadan should probably override the verse channel too, not only
   the dua, but that needs a scholar's view rather than mine.
3. Tier 2 topics risk becoming a filter bubble over scripture. A hard
   floor of unfiltered selection may be needed.
