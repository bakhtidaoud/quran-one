# Quran One - Product Backlog

**219 user stories across 13 modules.**

Priority: **P0** launch-blocking, **P1** launch target, **P2** post-launch.
Persona references map to `docs/UX_PERSONAS.md` (Sara/beginner, Ibrahim/scholar, Bilal/hafiz, Amina/professional, Khadija/parent, Zayd/child, Yusuf/revert, Musa/imam).

## Definition of Done (applies to every story)

- Meets acceptance criteria
- Unit and integration tested
- Works offline where applicable
- No ad or upsell surface introduced into a worship context
- Copy passes the no-guilt doctrine review
- Accessible: screen reader plus 200 percent text scaling
- Verified on reference mid-range Android (4GB RAM)
- No P0 regression in Athan delivery or sync integrity

---

## 1. Authentication (16)

**AUTH-01** (P0, Sara) As a new user, I want to use the entire app without an account, so that I can start reading immediately.
*AC:* All reading, audio, prayer, Qibla and dua features work anonymously; data persists locally across restarts; no sign-in wall in the first session.

**AUTH-02** (P0, Yusuf) As a user, I want to sign in with Apple, so that I can create an account without sharing my email.
*AC:* Apple Sign In available on iOS; private relay email accepted; account created in under 5 seconds.

**AUTH-03** (P0) As a user, I want to sign in with Google, so that I can register in one tap.
*AC:* Google Sign In on Android and web; returns to prior screen after auth.

**AUTH-04** (P0) As a user, I want to register with email and password, so that I do not depend on a third-party provider.
*AC:* Email format validated; password minimum 8 characters with strength indicator; verification email sent.

**AUTH-05** (P0, Bilal) As an anonymous user with local data, I want my bookmarks, notes and Hifz progress to migrate when I sign in, so that I lose nothing.
*AC:* All local entities upload on first sign-in; zero records dropped; progress bar shown; migration is idempotent if interrupted.

**AUTH-06** (P0) As a user, I want to sign in on a second device and see my data, so that I can read anywhere.
*AC:* Full sync within 10 seconds on a normal connection; reading position, bookmarks, notes and Hifz state all present.

**AUTH-07** (P0) As a user, I want to reset a forgotten password, so that I can regain access.
*AC:* Reset link emailed within 60 seconds; link expires in 1 hour; single use only.

**AUTH-08** (P0) As a user, I want to sign out, so that I can hand my device to someone else.
*AC:* Sign-out clears session and cached personal data; downloaded audio optionally retained with a prompt.

**AUTH-09** (P0) As a privacy-conscious user, I want to delete my account in-app, so that I do not have to email support.
*AC:* Self-service deletion in Settings; double confirmation; server data purged within 30 days; confirmation email sent.

**AUTH-10** (P0) As a user, I want to export my data before deleting my account, so that I keep my notes.
*AC:* JSON export offered in the deletion flow; includes notes, bookmarks, highlights and Hifz history.

**AUTH-11** (P1) As a user, I want to stay signed in indefinitely, so that I never re-authenticate during worship.
*AC:* Refresh token rotation; session survives app updates; re-auth only on explicit sign-out or revocation.

**AUTH-12** (P1) As a user, I want to see and revoke my active devices, so that I control access.
*AC:* Device list with name, platform and last active; revoke invalidates that device tokens immediately.

**AUTH-13** (P1, Amina) As a user, I want biometric lock on the app, so that my private notes stay private.
*AC:* Face ID or fingerprint toggle; fallback to device passcode; unlock required on cold start only.

**AUTH-14** (P1, Khadija) As a parent, I want to create child profiles under my account, so that each child has separate progress.
*AC:* Up to 5 child profiles; each with own progress and Hifz state; parent PIN to switch out of child mode.

**AUTH-15** (P2) As a user, I want to merge two accounts I created by accident, so that I keep all my history.
*AC:* Support-assisted merge; Hifz attempt logs unioned not overwritten; conflicting settings resolved by most recent.

**AUTH-16** (P2, Musa) As an institution admin, I want to invite students by link, so that I onboard a class quickly.
*AC:* Invite link with expiry; students join the roster on accept; admin sees pending vs accepted.

---

## 2. Home (15)

**HOME-01** (P0, Amina) As a busy user, I want to see the next prayer and a countdown the instant the app opens, so that I get my answer in one glance.
*AC:* Next prayer name and countdown above the fold; rendered within 2 seconds of cold start; correct after time-zone change.

**HOME-02** (P0, Sara) As a daily reciter, I want a Continue Reading card showing exactly where I stopped, so that I resume in one tap.
*AC:* Shows surah, page and verse; one tap opens that exact position; updates after every reading session.

**HOME-03** (P0, Bilal) As a Hifz student, I want today revision count on the home screen, so that I know my workload immediately.
*AC:* Shows total due plus breakdown (new, sabaq, sabqi, manzil); tap opens the session; hidden if no active plan.

**HOME-04** (P0) As a user, I want a Verse of the Day, so that I encounter something new daily.
*AC:* Same verse for all users on a given day; Arabic plus translation in my language; changes at local midnight.

**HOME-05** (P0) As a user, I want the home screen to work fully offline, so that connectivity never blocks me.
*AC:* All home cards render from local data with airplane mode on; no error states or spinners.

**HOME-06** (P1, Sara) As a returning user who missed days, I want to be welcomed back rather than told I failed, so that I do not feel judged.
*AC:* Copy reads Welcome back; no streak-broken language anywhere; no red or negative iconography.

**HOME-07** (P1) As a user, I want to reorder or hide home cards, so that the screen reflects my priorities.
*AC:* Drag to reorder; hide any card except next prayer; layout syncs across devices.

**HOME-08** (P1) As a user, I want my current reading plan progress on home, so that I see whether I am on track.
*AC:* Shows today target and completion; progress reflects partial reading; never displays a negative or shaming state.

**HOME-09** (P1) As a user, I want quick-action shortcuts to Qibla, Duas and Search, so that I reach common tasks in one tap.
*AC:* Three configurable shortcuts; reachable one-handed in the lower half of the screen.

**HOME-10** (P1, Amina) As a traveller, I want a non-blocking banner when my location changes, so that I can update prayer times without being interrupted.
*AC:* Banner offers Update or Keep current; dismissible; never a modal; appears only on genuine time-zone or over 100km change.

**HOME-11** (P1) As a user, I want a Ramadan home layout during Ramadan, so that seasonal needs are surfaced.
*AC:* Auto-activates on 1 Ramadan by Hijri setting; shows suhoor and iftar countdown; reverts automatically after Eid.

**HOME-12** (P2) As a user, I want a gentle reading streak indicator, so that I feel encouraged by consistency.
*AC:* Streak shown as a count only; pause states honoured; history never lost or silently reset.

**HOME-13** (P2, Zayd) As a child, I want a simplified home with big tappable cards, so that I can use it without reading much.
*AC:* Maximum 4 cards; icon plus audio label on each; no text-only navigation.

**HOME-14** (P2) As a user, I want to pull to refresh, so that I can force a sync.
*AC:* Pull triggers delta sync; shows last-synced time; fails silently to cached data when offline.

**HOME-15** (P2) As a user, I want a dhikr count card, so that I can resume my tasbih from home.
*AC:* Shows active dhikr and current count; one tap resumes; count survives app restart.

---

## 3. Quran (32)

**QUR-01** (P0, Sara) As a reader, I want the Uthmani mushaf in the 604-page Madani layout, so that it matches my physical Quran.
*AC:* All 604 pages page-faithful; line breaks match the printed Madani edition; verified by golden-file test per device class.

**QUR-02** (P0, Bilal) As a Hifz student, I want page breaks identical to my printed mushaf, so that my positional recall works.
*AC:* Zero page-break deviations across all 604 pages; CI fails on any diff.

**QUR-03** (P0) As a reader, I want a Mushaf mode I swipe through, so that reading feels like a book.
*AC:* Horizontal swipe page turns; sustained 60fps; under 1 percent dropped frames on 4GB Android.

**QUR-04** (P0, Sara) As a translation reader, I want a Verse list mode, so that I can read text and meaning together.
*AC:* Vertical scroll; Arabic with translation per verse; retains position on mode switch.

**QUR-05** (P0) As a reader, I want to navigate by surah, juz, hizb, page and ruku, so that I reach any location fast.
*AC:* All five navigation types available; jump-to-verse input accepts 2:255 format; reaches target in under 500ms.

**QUR-06** (P0, Ibrahim) As a scholar, I want the Arabic text verified against a canonical source, so that I can trust it.
*AC:* Text byte-identical to approved source; checksum validated on every launch; app blocks and reports on mismatch.

**QUR-07** (P0) As a multilingual user, I want at least 25 translations, so that I can read in my language.
*AC:* 25 or more at launch including 5 English, Urdu, French, Indonesian, Turkish, Bengali, Malay, German, Spanish, Russian; each with translator attribution visible.

**QUR-08** (P0, Sara) As a non-fluent reader, I want transliteration, so that I can recite before I can read Arabic.
*AC:* One documented scheme applied consistently everywhere; toggleable; never mixed with another scheme.

**QUR-09** (P0) As a reader, I want to bookmark a verse, so that I can return to it.
*AC:* Long-press to bookmark; appears in a bookmarks list; syncs across devices.

**QUR-10** (P0) As a reader, I want to add a private note to a verse, so that I record my reflections.
*AC:* Rich text note attached to verse reference; searchable; syncs; never visible to anyone else.

**QUR-11** (P0) As a reader, I want to highlight verses in 5 colours, so that I can categorise them visually.
*AC:* 5 colours; highlights persist and sync; visible in both reading modes.

**QUR-12** (P0) As a reader, I want to search Arabic without typing diacritics, so that search actually works.
*AC:* Diacritic-insensitive matching; results in under 300ms for a 3-character query; works offline.

**QUR-13** (P0) As a reader, I want to search translations and my own notes, so that I find things by meaning.
*AC:* Unified search across Arabic, translations and notes; results grouped by source type.

**QUR-14** (P0) As a reader, I want to control Arabic font, size and line spacing, so that I can read comfortably.
*AC:* Minimum 3 fonts including Uthmani Hafs and IndoPak; size scales to 200 percent without layout breakage.

**QUR-15** (P0) As a night reader, I want light, sepia, dark and true-black themes, so that reading is comfortable in any light.
*AC:* 4 themes; optional automatic switching by system setting; Arabic legibility verified in each.

**QUR-16** (P0) As a reader, I want my reading position saved automatically, so that I never lose my place.
*AC:* Position written locally on every page change; survives force-quit; syncs on debounce.

**QUR-17** (P0) As a reader, I want sajdah, waqf and juz markers rendered correctly, so that I recite properly.
*AC:* All markers present and positioned per the printed mushaf; sajdah triggers an optional reminder.

**QUR-18** (P0) As a reader, I want to share a verse as an image, so that I can send it to family.
*AC:* Generated image includes Arabic, translation, reference and app attribution; 3 template styles; no watermark upsell.

**QUR-19** (P0) As a reader, I want to copy a verse with its reference, so that I can quote it accurately.
*AC:* Copy includes Arabic, translation, surah:verse and translator name.

**QUR-20** (P0) As a reader, I want the entire mushaf available offline, so that I can read without connectivity.
*AC:* Full text and all translations available in airplane mode after initial pack download.

**QUR-21** (P1, Ibrahim) As a scholar, I want up to 3 translations side by side, so that I can compare renderings.
*AC:* 1 to 3 simultaneous translations; each labelled with translator; readable layout on phone and tablet.

**QUR-22** (P1, Yusuf) As a learner, I want word-by-word translation, so that I understand each word I recite.
*AC:* Tap any word for meaning, root and grammatical role; available offline; covers the full Quran.

**QUR-23** (P1, Ibrahim) As a scholar, I want to see all occurrences of a word root, so that I can study usage.
*AC:* Tap word then root then list of all occurrences with references; tappable to navigate.

**QUR-24** (P1, Ibrahim) As a scholar, I want tafsir from multiple named works, so that I can cross-reference.
*AC:* Ibn Kathir, Jalalayn, Sadi, Maariful Quran where licensed; edition disclosed; abridgement flagged explicitly.

**QUR-25** (P1) As a reader, I want tajweed colour-coding with a legend, so that I recite correctly.
*AC:* Toggleable; accurate rule colouring; legend accessible from the reader; works with all font choices.

**QUR-26** (P1) As a reader, I want reading plans (30, 60, 365-day, Ramadan), so that I complete the Quran with structure.
*AC:* Plan sets daily targets; progress tracked; missed days redistribute rather than break the plan.

**QUR-27** (P1, Ibrahim) As a tablet user, I want a two-page spread, so that the layout matches a physical mushaf.
*AC:* Two-page spread on tablets and web at sufficient width; correct RTL page ordering.

**QUR-28** (P1) As a reader, I want to see my reading history, so that I can revisit recent passages.
*AC:* Chronological list of sessions with surah, page range and duration; clearable.

**QUR-29** (P1, Ibrahim) As a scholar, I want to export my notes as Markdown, so that I can use them in my essays.
*AC:* Export preserves verse references; includes highlights and note text; downloadable on web.

**QUR-30** (P2) As a reader, I want thematic highlighting of topics, so that I can follow a subject across the Quran.
*AC:* Curated theme index; tap a theme to see all related verses; sourced and attributed.

**QUR-31** (P2, Sara) As a beginner, I want a short-surah starting point, so that I am not faced with 604 pages.
*AC:* Beginner mode surfaces Juz 30 first; transliteration and word-by-word on by default for this profile.

**QUR-32** (P2, Musa) As an imam, I want reference-ready citation copy, so that I prepare khutbah quickly.
*AC:* Copy format configurable; includes edition and translator; works for tafsir excerpts too.

---

## 4. Prayer (24)

**PRAY-01** (P0, Amina) As a user, I want prayer times calculated on-device, so that they work with no connectivity.
*AC:* All five times plus sunrise computed locally after one location fix; correct in airplane mode for at least 7 days ahead.

**PRAY-02** (P0) As a user, I want all major calculation methods available, so that my times match my community.
*AC:* MWL, ISNA, Egyptian, Umm al-Qura, Karachi, Tehran, Kuwait, Qatar, Singapore, Turkey, Moonsighting, Dubai, plus manual angle entry.

**PRAY-03** (P0) As a Hanafi user, I want to select the Asr juristic method, so that Asr is correct for me.
*AC:* Hanafi and Shafii options; change reflects immediately; no silently imposed default by region without disclosure.

**PRAY-04** (P0) As a high-latitude user, I want high-latitude rules, so that Fajr and Isha are usable in summer.
*AC:* Middle of night, one-seventh and angle-based options; auto-suggested above 48 degrees latitude.

**PRAY-05** (P0) As a user, I want per-prayer manual offsets, so that I can match my mosque exactly.
*AC:* Plus or minus 60 minute offset per prayer; applied to both display and notification.

**PRAY-06** (P0, Amina) As a traveller, I want automatic location and time-zone detection, so that times are right when I land.
*AC:* Detects time-zone change; recalculates and reschedules notifications; confirms non-blockingly.

**PRAY-07** (P0) As a user without location permission, I want to set my city manually, so that I still get accurate times.
*AC:* Searchable city list works offline for major cities; manual coordinates entry available.

**PRAY-08** (P0) As a user, I want Athan notifications at each prayer, so that I never miss one.
*AC:* Delivered within 30 seconds of the calculated time; 99.5 percent or better delivery verified across the OEM test matrix.

**PRAY-09** (P0) As a user, I want to choose the muadhin voice, so that the Athan sounds familiar.
*AC:* Minimum 5 muadhin options; previewable before selection; downloadable for offline use.

**PRAY-10** (P0, Amina) As a professional, I want per-prayer silent or vibrate mode, so that Athan never disrupts a meeting.
*AC:* Audible, vibrate and silent configurable per prayer independently; respects system focus modes.

**PRAY-11** (P0) As a user, I want a pre-prayer reminder, so that I can prepare.
*AC:* Configurable 5 to 60 minutes before; per-prayer on or off; separate sound from Athan.

**PRAY-12** (P0) As a user whose Athan did not arrive, I want a self-diagnostic, so that I can fix it myself.
*AC:* Test my Athan fires a real notification; detects OS-level suppression, battery optimisation and DND; gives device-specific instructions.

**PRAY-13** (P0) As a user, I want to see which method produced my times, so that I can debug a disagreement.
*AC:* Method name, angle values and offsets shown on the prayer screen; one tap to change.

**PRAY-14** (P1) As a user, I want an iqamah reminder after Athan, so that I pray in congregation on time.
*AC:* Configurable delay per prayer; separate notification; optional.

**PRAY-15** (P1, Amina) As a widget user, I want next prayer and countdown on my home screen, so that I do not open the app.
*AC:* iOS and Android widgets in 3 sizes; updates at least every 15 minutes; free for all users.

**PRAY-16** (P1, Amina) As an Apple Watch user, I want a prayer complication, so that I can glance at my wrist.
*AC:* Watch complication and Wear OS tile; shows next prayer and countdown; works when phone is absent where supported.

**PRAY-17** (P1) As a user, I want a monthly prayer timetable, so that I can plan ahead and print it.
*AC:* Full month view; exportable as PDF; reflects my method and offsets.

**PRAY-18** (P1) As a user, I want to log prayers as prayed, missed or qada, so that I can build consistency.
*AC:* One-tap logging from notification and app; private by default, stored on-device; never displays shaming language.

**PRAY-19** (P1) As a menstruating user, I want to pause prayer tracking without losing my streak, so that I am not penalised.
*AC:* Pause toggle; streak preserved not broken; no explanatory prompt required; fully private.

**PRAY-20** (P1) As a user, I want a Hijri calendar with adjustable offset, so that dates match my region.
*AC:* Plus or minus 2 day offset; key Islamic dates marked; Hijri date shown on the prayer screen.

**PRAY-21** (P1) As a user, I want fasting-day reminders, so that I do not forget Monday, Thursday and Ayyam al-Bid.
*AC:* Optional reminders the evening before; configurable per fast type.

**PRAY-22** (P2, Musa) As an imam, I want to publish my mosque iqamah times, so that my congregation stops phoning me.
*AC:* Verified mosque account can publish times; appears as an opt-in layer; never silently overrides calculated times.

**PRAY-23** (P2) As a user, I want to follow my local mosque times, so that I match congregation.
*AC:* Search and follow a mosque; times shown alongside calculated times, clearly labelled which is which.

**PRAY-24** (P2) As a user, I want a nearby mosque finder, so that I can pray in congregation while travelling.
*AC:* Map and list view; distance and direction; no ads or sponsored placements.

---

## 5. Qibla (10)

**QIB-01** (P0) As a user, I want a compass showing Qibla direction, so that I face correctly.
*AC:* Magnetometer-based bearing accurate within plus or minus 3 degrees; updates smoothly at 30fps or better.

**QIB-02** (P0) As a user, I want calibration guidance when the compass is unreliable, so that I trust the reading.
*AC:* Detects magnetic interference; shows figure-8 calibration animation; warns explicitly rather than showing a wrong bearing.

**QIB-03** (P0) As a user indoors, I want a map-based fallback, so that I can find Qibla when the compass fails.
*AC:* Map view with Qibla line from my location; works from last known location; usable offline with cached tiles.

**QIB-04** (P0) As a user, I want the distance to Makkah shown, so that I can sanity-check the direction.
*AC:* Great-circle distance in km or miles per my units setting.

**QIB-05** (P1) As a user, I want haptic feedback when I am aligned with Qibla, so that I do not have to stare at the screen.
*AC:* Haptic pulse within plus or minus 5 degrees of Qibla; toggleable.

**QIB-06** (P1) As a user, I want Qibla to work offline, so that it works while travelling without data.
*AC:* Calculation is purely local from coordinates; no network call required.

**QIB-07** (P1) As a visually impaired user, I want spoken Qibla guidance, so that I can align without seeing the screen.
*AC:* VoiceOver and TalkBack announce bearing and alignment; turn left or right guidance.

**QIB-08** (P1) As a user, I want to reach Qibla from the Athan notification, so that I get there in one tap.
*AC:* Notification action opens Qibla directly.

**QIB-09** (P2) As a user, I want an AR camera Qibla overlay, so that I can see the direction in my room.
*AC:* Camera overlay with directional indicator; graceful fallback if AR unsupported; optional, never the default.

**QIB-10** (P2, Zayd) As a child, I want a simple visual Qibla, so that I understand which way to face.
*AC:* Large arrow, minimal text, audio confirmation when aligned.

---

## 6. Hadith (12)

**HAD-01** (P1) As a user, I want access to major hadith collections, so that I can study authentic narrations.
*AC:* Bukhari, Muslim and the four Sunan where licensed; Arabic plus translation; offline after download.

**HAD-02** (P1, Ibrahim) As a scholar, I want each hadith grading shown, so that I know its authenticity status.
*AC:* Grading displayed with the grading authority named; never presented without attribution.

**HAD-03** (P1, Ibrahim) As a scholar, I want full chain and reference metadata, so that I can cite properly.
*AC:* Collection, book, chapter and hadith number shown; copy includes all reference data.

**HAD-04** (P1) As a user, I want to search hadith by keyword, so that I can find a narration I half-remember.
*AC:* Searches Arabic and translation; diacritic-insensitive; results in under 500ms offline.

**HAD-05** (P1) As a user, I want to browse hadith by topic, so that I can study a subject.
*AC:* Curated topical index; each topic lists relevant hadith with grading visible.

**HAD-06** (P1) As a user, I want to bookmark and note hadith, so that I can build a personal collection.
*AC:* Same bookmark, note and highlight model as Quran verses; syncs across devices.

**HAD-07** (P1) As a user, I want hadith related to a Quran verse surfaced, so that I understand context.
*AC:* Verse study panel shows linked hadith where a sourced link exists; links are curated, never inferred by AI.

**HAD-08** (P1) As a user, I want to share a hadith with its grading, so that I do not spread weak narrations.
*AC:* Share text and image always include grading and reference; grading cannot be omitted.

**HAD-09** (P2) As a user, I want a daily hadith, so that I learn something each day.
*AC:* One hadith per day, sahih only; consistent across users; optional notification.

**HAD-10** (P2) As a user, I want hadith audio, so that I can listen while commuting.
*AC:* Arabic audio where licensed; background playback.

**HAD-11** (P2, Musa) As an imam, I want to build and share a hadith collection, so that I can teach from it.
*AC:* Create named collections; share via link; recipients see gradings and sources.

**HAD-12** (P2) As a user, I want to report a hadith content error, so that mistakes get fixed.
*AC:* In-app report routed to the review board; 48-hour triage commitment; fixable via content update without an app release.

---

## 7. Azkar (14)

**AZK-01** (P0) As a user, I want a curated dua library, so that I can supplicate with authentic wordings.
*AC:* Hisnul Muslim based; Arabic, transliteration, translation and source reference on every dua; offline.

**AZK-02** (P0) As a user, I want morning and evening adhkar with a guided counter, so that I complete them correctly.
*AC:* Ordered sequence; per-item target count; tap to increment; progress saved if interrupted.

**AZK-03** (P0) As a user, I want every dua source shown, so that I know it is authentic.
*AC:* Collection and reference visible on each dua; no unsourced dua ships.

**AZK-04** (P0) As a user, I want duas available offline, so that I can use them anywhere.
*AC:* Full library and audio if downloaded work in airplane mode.

**AZK-05** (P1) As a user, I want a digital tasbih with haptics, so that I can count dhikr without beads.
*AC:* Configurable target (33, 100, custom); haptic per tap and at target; count survives app restart and screen lock.

**AZK-06** (P1) As a user, I want dua audio, so that I can learn correct pronunciation.
*AC:* Audio for all duas in the core library; playback speed control; downloadable.

**AZK-07** (P1) As a user, I want to favourite duas, so that I reach my regular ones quickly.
*AC:* Favourites list; reorderable; syncs across devices.

**AZK-08** (P1) As a user, I want to create custom dua collections, so that I can group them by situation.
*AC:* Named collections; add and remove duas; syncs.

**AZK-09** (P1) As a user, I want adhkar reminders at chosen times, so that I build the habit.
*AC:* Separate reminders for morning and evening adhkar; configurable times; respects quiet hours.

**AZK-10** (P1) As a user, I want post-prayer adhkar surfaced after Athan, so that I do not forget them.
*AC:* Optional prompt after logging a prayer; dismissible; never nagging.

**AZK-11** (P2) As a user, I want contextual dua suggestions, so that I find the right dua for my situation.
*AC:* Categories for travel, illness, sleep, exams and distress; surfaced by category browse, not inferred from personal data.

**AZK-12** (P2, Sara) As a beginner, I want the most essential duas marked, so that I know where to start.
*AC:* Start here set of 10 duas; shown first in beginner mode.

**AZK-13** (P2, Zayd) As a child, I want to learn duas by listening and repeating, so that I memorise them.
*AC:* Audio-first flow; listen, repeat, confirm; encouragement-only feedback.

**AZK-14** (P2) As a user, I want to share a dua as an image, so that I can send it to family.
*AC:* Image includes Arabic, translation and source reference.

---

## 8. Ramadan (14)

**RAM-01** (P1) As a fasting user, I want suhoor and iftar countdowns, so that I time my fast correctly.
*AC:* Live countdown to next event; derived from Fajr and Maghrib with my method and offsets; works offline.

**RAM-02** (P1) As a fasting user, I want suhoor and iftar notifications, so that I do not miss them.
*AC:* Configurable pre-suhoor reminder up to 60 min; iftar notification at Maghrib; separate sounds.

**RAM-03** (P1) As a user, I want a Ramadan home layout, so that seasonal needs are front and centre.
*AC:* Auto-activates on 1 Ramadan by my Hijri setting; reverts after Eid al-Fitr; manually overridable.

**RAM-04** (P1) As a user, I want a Ramadan Quran plan, so that I complete the Quran in the month.
*AC:* 30-juz-in-30-days plan; daily target with progress; missed days redistribute across remaining days.

**RAM-05** (P1) As a user, I want a Ramadan calendar with the full month timings, so that I can plan.
*AC:* Suhoor and iftar times for all 30 days; exportable as PDF; reflects my location and method.

**RAM-06** (P1) As a user, I want to track completed fasts, so that I know which I owe.
*AC:* Log fasted, missed or exempt per day; qada list generated; private and on-device by default.

**RAM-07** (P1) As a menstruating user, I want to mark exempt days without penalty, so that tracking respects my situation.
*AC:* Exempt state does not count as missed; no streak break; no explanation required.

**RAM-08** (P1) As a user, I want taraweeh tracking, so that I follow the nightly recitation.
*AC:* Nightly juz portion shown; marks progress; aligns with the standard 20-rakah schedule.

**RAM-09** (P2) As a user, I want Laylatul Qadr reminders in the last ten nights, so that I do not miss them.
*AC:* Optional nightly reminders for nights 21 to 30; odd nights emphasised; configurable.

**RAM-10** (P2) As a user, I want an itikaf mode, so that notifications reduce during retreat.
*AC:* Suppresses all non-prayer notifications for a chosen date range.

**RAM-11** (P2) As a user, I want a zakat al-fitr reminder before Eid, so that I pay on time.
*AC:* Reminder before Eid al-Fitr; informational only, no payment processing, no sponsored links.

**RAM-12** (P2, Khadija) As a parent, I want family Ramadan routines, so that my household shares the schedule.
*AC:* Shared countdown across family profiles; simple household plan; child-appropriate presentation.

**RAM-13** (P2) As a user, I want Eid prayer time and takbir, so that I am ready for Eid morning.
*AC:* Eid prayer time estimate with method disclosed; takbir audio and text.

**RAM-14** (P2) As a returning Ramadan user, I want a post-Ramadan continuation prompt, so that I keep the habit.
*AC:* Suggests a lighter ongoing plan after Eid; encouragement only, easily dismissed, never repeated more than twice.

---

## 9. Learning (18)

**LRN-01** (P1, Yusuf) As a new Muslim, I want a guided learning path that tells me what to learn next, so that I am not guessing.
*AC:* Ordered path from salah mechanics to short surahs to Arabic letters to reading fluency to comprehension; progress tracked; resumable.

**LRN-02** (P1, Yusuf) As a new Muslim, I want step-by-step salah instruction, so that I can pray correctly and confidently.
*AC:* Each posture with Arabic, transliteration, translation and audio; madhhab differences labelled where they exist; covers all five prayers.

**LRN-03** (P1, Sara) As a beginner, I want to learn the Arabic alphabet, so that I can start reading.
*AC:* Letter-by-letter lessons with audio; isolated, initial, medial and final forms; practice exercises.

**LRN-04** (P1) As a learner, I want to learn Arabic letter joining, so that I can read words.
*AC:* Progressive joining lessons; builds to reading short words; audio for each.

**LRN-05** (P1, Sara) As a beginner, I want tajweed rules taught with examples, so that I recite correctly.
*AC:* Each rule explained with audio examples from the Quran; linked to tajweed colouring in the reader.

**LRN-06** (P1, Yusuf) As a learner, I want spaced repetition for Quranic vocabulary, so that I retain what I learn.
*AC:* Reuses the Hifz scheduling engine; vocabulary decks by frequency; offline capable.

**LRN-07** (P1) As a learner, I want to learn the most frequent Quranic words first, so that my effort has maximum return.
*AC:* Frequency-ordered vocabulary list; coverage percentage shown as I progress.

**LRN-08** (P1) As a learner, I want audio slowed to 0.5x with pitch preserved, so that I can hear each syllable.
*AC:* 0.5x to 2.0x range; no pitch distortion; applies in lessons and the reader.

**LRN-09** (P1, Sara) As a self-conscious learner, I want private recitation practice, so that nobody hears my mistakes.
*AC:* Recording stored on-device only; never uploaded without explicit action; deletable.

**LRN-10** (P1) As a learner, I want to record and compare myself against a reciter, so that I can self-correct.
*AC:* Side-by-side playback; waveform alignment; no scoring or judgement.

**LRN-11** (P1) As a learner, I want quizzes on what I have learned, so that I can check my understanding.
*AC:* Multiple-choice and recall formats; encouragement-only feedback; never a failure state.

**LRN-12** (P1) As a learner, I want my lesson progress synced, so that I can study on any device.
*AC:* Path position and completed lessons sync; web parity.

**LRN-13** (P2, Yusuf) As a learner, I want to learn the meaning of prayer phrases, so that I understand what I say in salah.
*AC:* Word-by-word breakdown of every salah phrase with audio.

**LRN-14** (P2, Zayd) As a child, I want audio-first lessons with pictures, so that I can learn before I can read.
*AC:* Every instruction spoken; no reliance on reading; 5 to 10 minute units with a celebrated ending.

**LRN-15** (P2) As a learner, I want Islamic fundamentals lessons, so that I understand the basics of practice.
*AC:* Pillars, wudu, ghusl, fasting rules; all content scholar-reviewed and sourced; madhhab differences labelled.

**LRN-16** (P2, Sara) As a learner, I want to see my Arabic reading speed improving, so that progress feels real beyond page counts.
*AC:* Optional self-timed reading measurement; trend chart; framed as progress, never as a deficit.

**LRN-17** (P2, Musa) As a teacher, I want to assign lessons to students, so that I can structure a class.
*AC:* Assign lesson or verse range to roster members; see completion per student.

**LRN-18** (P2) As a learner, I want offline lessons, so that I can study without data.
*AC:* Lesson content and audio downloadable; full functionality in airplane mode.

---

## 10. AI Assistant (14)

> **Governing constraint on this module:** the assistant never issues religious rulings, never generates Quranic or hadith text, and always cites sources. It assists, cites and defers to scholars. Every story below inherits this.

**AI-01** (P2) As a user, I want to ask a natural-language question and get answers grounded in the Quran and hadith, so that I can find relevant sources.
*AC:* Every response cites specific verses or hadith with references; no answer without a citation; refuses rather than speculates.

**AI-02** (P2) As a user, I want the assistant to refuse to give fatwa, so that I am not misled on rulings.
*AC:* Ruling-seeking questions return a refusal plus a suggestion to consult a scholar; never produces a ruling, even hedged.

**AI-03** (P2) As a user, I want to find a verse from a vague description, so that I can locate half-remembered passages.
*AC:* Semantic search over Quran and translations; returns ranked verses with references; never paraphrases the text as if quoting it.

**AI-04** (P2) As a user, I want thematic exploration of a topic, so that I can study it across sources.
*AC:* Returns a sourced list of verses and hadith with gradings; no synthesised religious conclusions.

**AI-05** (P2, Ibrahim) As a scholar, I want the assistant to show which sources it used, so that I can verify it.
*AC:* Every claim traceable to a specific cited source; sources tappable to open in the reader.

**AI-06** (P2) As a user, I want the assistant to say when it does not know, so that I do not get fabrications.
*AC:* Explicit uncertainty statement when confidence is low; no hallucinated references; references validated against the content database before display.

**AI-07** (P2, Yusuf) As a new Muslim, I want to ask basic practice questions without embarrassment, so that I can learn privately.
*AC:* Private by default; conversations stored on-device unless explicitly synced; never used for training without opt-in.

**AI-08** (P2) As a user, I want translation and word explanation on demand, so that I understand a specific phrase.
*AC:* Explains grammar and root for any word; draws from the morphology database, not generation.

**AI-09** (P2) As a user, I want to ask about a verse I am reading, so that I get contextual help in place.
*AC:* Assistant invoked from the verse action sheet; has the verse in context; answers cite tafsir where available.

**AI-10** (P2) As a privacy-conscious user, I want my AI conversations excluded from training, so that my religious questions stay private.
*AC:* No training on user conversations; stated plainly in-product; opt-in only, off by default.

**AI-11** (P2) As a user, I want to report a bad AI answer, so that it gets reviewed.
*AC:* Report action on every response; routed to the review board; patterns tracked and published in quality reporting.

**AI-12** (P2) As a user, I want the assistant to work in my language, so that I can ask naturally.
*AC:* Supports the 12 launch UI languages; citations shown in both Arabic and my language.

**AI-13** (P2) As a user, I want a clear disclosure that this is AI, so that I calibrate my trust.
*AC:* Persistent, non-dismissible label; first-use explanation of limits and the no-rulings policy.

**AI-14** (P2, Musa) As an imam, I want assistant answers reviewed by scholars in aggregate, so that I can trust recommending it.
*AC:* Sampled responses audited by the review board each release; findings published; systematic errors block release.

---

## 11. Premium (16)

**PRM-01** (P0) As any user, I want the Arabic Quran text and the five prayer times to never be paywalled, so that worship is never blocked by money.
*AC:* Hard product invariant; automated test asserts these are reachable without entitlement; violation blocks release.

**PRM-02** (P0) As a free user, I want a genuinely sufficient free tier, so that I can practise fully without paying.
*AC:* Free includes full mushaf, all translations, transliteration, search, prayer times, Athan, Qibla, duas and 5 or more reciters with offline download.

**PRM-03** (P0) As a user, I want zero advertising anywhere, so that worship is never interrupted.
*AC:* No ad SDKs in the build; automated dependency check in CI; violation blocks release.

**PRM-04** (P0) As a user, I want to see clearly what Plus includes and what stays free forever, so that I can decide honestly.
*AC:* Value screen lists both columns explicitly; free-tier guarantee stated; no dark patterns or fake scarcity.

**PRM-05** (P0) As a user, I want monthly, annual and lifetime options, so that I can choose what suits me.
*AC:* Three plans; annual shows honest per-month equivalent; one lifetime price per region, never multiple concurrent lifetime prices.

**PRM-06** (P0, Bilal) As a user in a lower-income country, I want regional pricing, so that Plus is affordable.
*AC:* Purchasing-power-parity ladder across Tier 1, 2 and 3; consistent within a market; published.

**PRM-07** (P0) As a subscriber, I want my entitlement to work offline, so that I keep access without connectivity.
*AC:* Entitlement cached locally, valid 30 days offline; server-side receipt validation on reconnect.

**PRM-08** (P0) As a subscriber, I want to restore my purchase on a new device, so that I do not pay twice.
*AC:* Restore Purchases works via store receipt and via account; succeeds without support contact.

**PRM-09** (P0) As a user declining to subscribe, I want to never be told I am religiously obliged to pay, so that I am not manipulated.
*AC:* No copy implies religious failure, obligation or divine judgement about payment; enforced in copy review; violation is a P0 defect.

**PRM-10** (P0) As a user, I want the paywall never to appear over Quranic text or prayer times, so that worship is uninterrupted.
*AC:* Paywall cannot render over the reader or prayer screen; automated UI test asserts this.

**PRM-11** (P1) As a user who cannot afford Plus, I want to request sponsored access, so that cost is not a barrier.
*AC:* Cannot afford it path on the paywall; request grants access from the Waqf pool; no proof of income required; no public disclosure of recipients.

**PRM-12** (P1) As a generous user, I want to fund subscriptions for others, so that I earn sadaqah jariyah.
*AC:* Gift or sponsor flow; transparent reporting of how many were funded; recipients never identified.

**PRM-13** (P1) As a subscriber, I want to cancel easily, so that I am not trapped.
*AC:* Cancellation path visible in Settings; links to store subscription management; no retention dark patterns or guilt copy.

**PRM-14** (P1) As a long-term free user, I want features I already rely on to never move behind a paywall, so that I keep trusting the product.
*AC:* Published guarantee: features may move into free, never out; grandfathering enforced on any tier change.

**PRM-15** (P1, Khadija) As a parent, I want one family price, so that I do not pay per child.
*AC:* Family plan covers up to 6 profiles; single price; all child features included.

**PRM-16** (P2, Musa) As an institution, I want a mosque or school licence, so that I cover my students affordably.
*AC:* Seat-based institutional pricing; admin console; invoice payment supported.

---

## 12. Settings (20)

**SET-01** (P0) As a user, I want to change my app language, so that I can use it in my own language.
*AC:* 12 languages at launch; full RTL for Arabic, Urdu and Farsi; no untranslated strings.

**SET-02** (P0) As a user, I want to choose my default translation, so that I do not reselect every time.
*AC:* One recommended default per language pre-selected with a one-line reason; changeable.

**SET-03** (P0) As a user, I want to choose and download reciters, so that I control storage.
*AC:* Per-reciter, per-surah and per-juz download scopes; size shown before download; Wi-Fi-only toggle on by default.

**SET-04** (P0) As a user, I want a storage manager, so that I can free space.
*AC:* Per-reciter and per-content usage shown; one-tap cleanup; warns before starting a download that would exceed free space.

**SET-05** (P0) As a user, I want to configure all prayer calculation settings in one place, so that I can get times right.
*AC:* Method, Asr juristic, high-latitude rule and per-prayer offsets grouped together; plain-language explanations, not jargon alone.

**SET-06** (P0) As a user, I want to configure notifications per type, so that I only get what I want.
*AC:* Independent control for Athan, pre-prayer, iqamah, reading, adhkar and Hifz; each with sound, vibrate or silent.

**SET-07** (P0) As a user, I want quiet hours, so that I am not disturbed at night.
*AC:* Configurable window; suppresses all non-Athan notifications; Athan suppression is opt-in and explicitly confirmed.

**SET-08** (P0) As a user, I want a reduce notifications master switch, so that I can quieten everything at once.
*AC:* Single toggle reduces all optional notifications; Athan preserved unless separately disabled.

**SET-09** (P0) As a privacy-conscious user, I want to read a plain-language privacy summary, so that I understand what is collected.
*AC:* Readable in under 5 minutes; lists every data category and purpose; linked from onboarding and Settings.

**SET-10** (P0) As a privacy-conscious user, I want to opt out of analytics without losing features, so that privacy costs me nothing.
*AC:* Opt-out toggle; no feature degradation; takes effect immediately.

**SET-11** (P0) As a user, I want to control my typography, so that reading is comfortable.
*AC:* Arabic font, Arabic size, translation size and line spacing; all persist and sync.

**SET-12** (P0) As a user, I want to select my theme, so that reading suits my environment.
*AC:* Light, sepia, dark and true-black; optional auto-switch by system setting.

**SET-13** (P0) As a user, I want to see the app data-handling and SDK list, so that I can verify the privacy claims.
*AC:* Full third-party SDK list published in-app and in the repository; confirms zero ad or data-broker SDKs.

**SET-14** (P1) As a user, I want to set my Hijri date offset, so that dates match my region.
*AC:* Plus or minus 2 days; applies to calendar, Ramadan detection and fasting reminders.

**SET-15** (P1) As an accessibility user, I want the app to respect OS text scaling and reduced motion, so that it is usable for me.
*AC:* Honours system text size to 200 percent without layout breakage; reduced-motion disables page-turn animation.

**SET-16** (P1) As a user, I want high-contrast and dyslexia-friendly translation text, so that I can read comfortably.
*AC:* High-contrast mode; dyslexia-friendly font option for translation text only, never for Quranic Arabic.

**SET-17** (P1) As a user, I want to control sync behaviour, so that I manage my data usage.
*AC:* Sync on Wi-Fi only option; manual sync trigger; last-synced timestamp shown.

**SET-18** (P1) As a user, I want to export all my data, so that I own it.
*AC:* JSON export including notes, bookmarks, highlights, Hifz history and settings; available on mobile and web.

**SET-19** (P2) As a user, I want to import previously exported data, so that I can restore or migrate.
*AC:* Import validates schema; merges without duplicating; reports what was imported.

**SET-20** (P2, Khadija) As a parent, I want child-mode restrictions, so that my child cannot change settings or leave the app.
*AC:* PIN-protected exit from child mode; no external links reachable; no in-app purchase reachable.

---

## 13. Dashboard (14)

**DASH-01** (P1) As a user, I want a personal dashboard of my activity, so that I can see my practice over time.
*AC:* Reading, listening, Hifz, prayer and dhikr summarised; all data private by default; framed as progress, never deficit.

**DASH-02** (P1) As a user, I want my reading statistics, so that I understand my habits.
*AC:* Pages, verses and minutes by day, week and month; charts render offline from local data.

**DASH-03** (P1, Bilal) As a Hifz student, I want detailed memorisation statistics, so that I can manage my progress.
*AC:* Verses memorised, juz completed, mastery distribution, revision accuracy and projected completion date.

**DASH-04** (P1, Bilal) As a Hifz student, I want a weakness report, so that I know which verses are decaying.
*AC:* Lists verses with lowest recall accuracy, ranked; one tap to add them to today revision queue.

**DASH-05** (P1) As a user, I want to see my prayer consistency, so that I can improve.
*AC:* Calendar heatmap of logged prayers; exempt and paused days visually distinct from missed; no shaming language or colour.

**DASH-06** (P1) As a user, I want my dashboard to work offline, so that I can review anywhere.
*AC:* All charts computed from local data; no loading states in airplane mode.

**DASH-07** (P1) As a user, I want my streak history preserved permanently, so that it is never silently lost.
*AC:* Streak history stored server-side with versioning; spurious resets impossible; restorable from 30-day backup.

**DASH-08** (P1) As a user, I want reading plan progress with realistic projections, so that I know if I will finish.
*AC:* Shows target vs actual and a projected completion date; adjusts for missed days without breaking the plan.

**DASH-09** (P2, Bilal) As a Hifz student, I want to export a progress report as PDF, so that I can show my teacher.
*AC:* PDF includes mastery per juz, revision accuracy and date range; shareable.

**DASH-10** (P2, Khadija) As a parent, I want a weekly summary of each child activity, so that I can support them.
*AC:* Per-child weekly view; age-banded detail (full under 10, summary 10 to 13, self-managed 14 plus); child aware they are monitored.

**DASH-11** (P2, Musa) As a teacher, I want a roster dashboard showing all students, so that I can see who is behind.
*AC:* Sortable by progress and last activity; per-student drill-down into mastery and weak verses.

**DASH-12** (P2, Musa) As a teacher, I want to assign verse ranges and see completion, so that I can run a class.
*AC:* Assign range with due date per student or whole class; completion status visible; students notified.

**DASH-13** (P2) As a user, I want yearly-in-review insights, so that I can reflect on my year.
*AC:* Annual summary generated locally; shareable as an image; entirely opt-in, never pushed as a notification.

**DASH-14** (P2) As a user, I want to reset my statistics, so that I can start fresh.
*AC:* Reset with double confirmation; clearly states what is deleted; Hifz mastery data reset is a separate, explicit action.

---

## Backlog summary

| Module | Stories | P0 | P1 | P2 |
| --- | --- | --- | --- | --- |
| Authentication | 16 | 10 | 4 | 2 |
| Home | 15 | 5 | 6 | 4 |
| Quran | 32 | 20 | 9 | 3 |
| Prayer | 24 | 13 | 8 | 3 |
| Qibla | 10 | 4 | 4 | 2 |
| Hadith | 12 | 0 | 8 | 4 |
| Azkar | 14 | 4 | 6 | 4 |
| Ramadan | 14 | 0 | 8 | 6 |
| Learning | 18 | 0 | 12 | 6 |
| AI Assistant | 14 | 0 | 0 | 14 |
| Premium | 16 | 10 | 5 | 1 |
| Settings | 20 | 13 | 5 | 2 |
| Dashboard | 14 | 0 | 8 | 6 |
| **Total** | **219** | **79** | **83** | **57** |

**Sprint sequencing:** the 79 P0 stories are the launch gate and map to PRD Phases 0 and 1 (reader, audio, prayer, duas, offline, settings, premium invariants). Hifz stories sit in a dedicated epic, deliberately not diluted across modules, because it is the differentiator.

## Product owner notes

1. **The AI Assistant module is entirely P2, and that is intentional.** Every story in it carries a hard constraint: no rulings, no generated scripture, mandatory citations. If we cannot guarantee those, we ship none of it. Shipping a hallucinated hadith reference would cost more trust than the whole module could ever earn.
2. **Four stories are invariants, not features:** PRM-01, PRM-03, PRM-09, PRM-10. They are written as automated tests that block release, not as things a team does. That is the only way an ad-free, no-guilt promise survives commercial pressure two years from now.
