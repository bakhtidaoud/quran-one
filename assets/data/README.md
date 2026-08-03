# Bundled data

`surah_index.json` is a seed index: 114 rows, roughly 12 KB. It ships in the
bundle because every screen needs it and it never changes.

`arabic_name` is intentionally empty in this seed. Arabic surah names arrive
with the signed content pack alongside the Uthmani text, so that every
Arabic glyph the app renders has passed the same verification step. Nothing
in Arabic script is hand-typed into the repository.

`start_page` follows the 604-page Madani mushaf. These values are seeds and
must be reconciled against the licensed page-break data before launch - page
boundary drift is risk AR-1 and it is the single most visible defect a Quran
app can ship.

Scripture itself is never an asset. It is a versioned, checksummed content
pack downloaded once and stored in SQLite, which is what lets a correction
ship without an app release.
