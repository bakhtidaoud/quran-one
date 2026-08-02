# Quran One - Typography System

Codename: Mizan. Companion to DESIGN_SYSTEM.md and COLOR_SYSTEM.md.

---

## 0. The core problem

Arabic and Latin do not share a metric model. Latin has x-height, cap height, ascenders and descenders. Arabic has a baseline, a variable vertical extent, and a diacritical zone above and below that can double line height without warning.

Consequence: setting Arabic and Latin at the same fontSize produces Arabic that looks 10-15 percent too small. Every competitor does this.

This system solves it with three mechanisms: a per-script optical scale factor, script-aware line-height minimums, and a strut that keeps mixed-script lines from jumping.

---

## 1. Arabic fonts

| Tier | Face | Where | Why |
| --- | --- | --- | --- |
| Quranic | KFGQPC Uthmanic Hafs | Mushaf only | The King Fahd Complex face. Reference for the printed Madani mushaf and the only face for which our page_line glyph positions are valid. |
| UI | IBM Plex Sans Arabic | All interface chrome | Humanist sans with genuine multi-weight coverage (100-700, all real masters). Excellent small-size legibility. Shares construction logic with Inter. |
| Long-form reading | Noto Naskh Arabic | Arabic translations, tafsir, hadith | A proper naskh. Sans-serif Arabic is fine for labels and wrong for sustained prose. |

### 1.1 The Quranic face is content, not style

KFGQPC Uthmanic Hafs ships inside the content pack, versioned with the text it renders, not bundled in the app binary.

This addresses AR-1. A font substitution or version bump changes glyph advance widths, which changes line breaks, which changes page composition. The 604-page layout is a typographic contract. Ship text and font as one atomic checksummed unit or the golden-file suite is testing a moving target.

### 1.2 Faces considered and rejected

| Face | Verdict |
| --- | --- |
| Cairo | Rejected. Geometric construction, weak diacritic differentiation at UI sizes. |
| Tajawal | Rejected. Similar issues plus incomplete weight coverage. |
| Amiri | Beautiful naskh, low effective size, delicate strokes struggle below 18sp. Held as tafsir alternate. |
| Scheherazade New | Retained as public-domain fallback for AR-4 (licence withdrawal). SIL-licensed and complete. |
| Noto Nastaliq Urdu | Deferred to 2028 with the Indo-Pak script pack. Nastaliq's diagonal baseline needs a different line model. |

---

## 2. English fonts

| Face | Where | Why |
| --- | --- | --- |
| Inter | All interface chrome | Designed for screens at UI sizes. Tall x-height, unambiguous Il1 and O0, variable weight axis. |
| Literata | English translations, tafsir, long-form prose | Screen-first serif commissioned for Google Books. Sturdy slab-influenced serifs survive antialiasing. |
| Inter tabular | Times, verse numbers, counters, durations | tnum on. Proportional digits jitter in a countdown. |

Rejected: SF Pro and Roboto (platform defaults produce a different product per OS); Poppins and Montserrat (geometric, poor at small sizes, single-storey a reduces reading speed); any display face for headings.

---

## 3. Font pairing

```
UI PAIR        Inter     + IBM Plex Sans Arabic
READING PAIR   Literata  + Noto Naskh Arabic
SACRED         KFGQPC Uthmanic Hafs (unpaired, alone)
```

Inter and IBM Plex Sans Arabic are both humanist rather than geometric, both drawn for screen rendering at UI sizes. Their counters and stroke contrast sit close enough that a bilingual settings screen reads as one typeface.

Literata and Noto Naskh Arabic pair on tone rather than shape. Both signal sustained reading rather than interface. Both hold up at 16-20sp.

KFGQPC Uthmanic Hafs pairs with nothing and is never set alongside another face on the same line.

Rule: one pair per surface. A screen may use the UI pair or the reading pair, never both. The reader is the sole exception, and its chrome auto-hides.

---

## 4. Weights

| Weight | Inter | IBM Plex Sans Arabic | Literata | Noto Naskh Arabic |
| --- | --- | --- | --- | --- |
| 400 Regular | yes | yes | yes | yes |
| 500 Medium | yes | yes | yes | no |
| 600 SemiBold | yes | yes | yes | no |
| 700 Bold | yes | yes | yes | yes |

Rules:

1. Four weights ship: 400, 500, 600, 700. Anything else is deleted from the bundle.
2. Synthetic bold and synthetic italic are banned on Arabic. Faux-bolding thickens strokes uniformly, closes counters, and destroys join geometry. If a weight has no real master, that emphasis level does not exist in Arabic.
3. Noto Naskh Arabic has only 400 and 700. Any element using 500 or 600 degrades to 400 in Arabic long-form, never to 700.
4. Italic does not exist in Arabic. Where Latin uses italic, Arabic uses colour and indentation.

---

## 5. Letter spacing

| Script | Rule |
| --- | --- |
| Arabic, all contexts | Always 0. No exceptions. |
| Latin display and headline | Negative, -0.25 to -0.5 |
| Latin body | +0.15 to +0.5 per M3 |
| Latin labels | +0.5, up to +1.0 at 11sp |

The Arabic rule is structural, not stylistic. Arabic is a joining script. Positive letterSpacing in Flutter inserts space between glyphs, visibly breaking connecting strokes. Negative tracking collides the joins.

Enforced by lint: any TextStyle with non-zero letterSpacing that could resolve to an Arabic font fails the build.

---

## 6. Line height

Flutter's height is a multiplier of fontSize. All figures are multipliers.

| Context | Latin | Arabic | Why the gap |
| --- | --- | --- | --- |
| Display | 1.12 | 1.45 | Diacritic clearance even at display sizes |
| Headline | 1.28 | 1.55 | |
| Title | 1.30 | 1.55 | |
| Body and UI | 1.45 | 1.70 minimum | Below 1.6, fatha touches kasra on the next line |
| Long-form reading | 1.65 | 1.80 minimum | |
| Vocalised Quranic | n/a | 2.00 minimum | Harakat plus sukun, shadda, madd and waqf marks |
| Label and caption | 1.40 | 1.60 | |

The floor is applied at resolution time, not left to callers.

Every Arabic and Quranic style sets leadingDistribution: TextLeadingDistribution.even. Flutter's default proportional distribution follows the font's ascent/descent ratio, which for Arabic is dominated by the diacritic zone, dumping space above the line and cramping descenders.

---

## 7. The Arabic optical scale factor

```dart
const double kArabicScale = 1.10;
```

Arabic at the same nominal fontSize appears about 10 percent smaller because Latin's perceived size is x-height driven and Arabic has no x-height. Every UI style multiplies fontSize by this factor when the resolved script is Arabic.

| Style | Latin | Arabic |
| --- | --- | --- |
| body.large | 16 | 17.6 |
| body.medium | 14 | 15.4 |
| label.small | 11 | 12.1 |

Exception: Noto Naskh Arabic uses 1.15, because naskh sits lower and smaller in its em box. The factor is a property of the face, not the script, and lives in the font registry.

---

## 8. Hierarchy

```
LEVEL 0   Quranic text        largest, highest contrast, alone on the canvas
LEVEL 1   Translation         clearly subordinate, serif
LEVEL 2   Screen title        Inter 600 / Plex 600
LEVEL 3   Section header      smaller 600, or label.large uppercase
LEVEL 4   Body / list content Inter 400
LEVEL 5   Metadata, captions  Inter 400 at secondary colour
LEVEL 6   Disabled, hints     Inter 400 at 3:1
```

1. Level 0 outranks everything including the app bar. If a heading competes with the ayah, the heading is wrong.
2. Never more than three levels visible in one viewport.
3. Hierarchy is carried by size and weight, not colour. Colour marks state; type marks rank.
4. Uppercase is used only at label.small and never on Arabic. In Arabic locales the same header uses weight instead.

---

## 9. Type styles

Sizes in logical pixels. LH is line-height multiplier (Latin / Arabic). LS is letter spacing.

### 9.1 Display

Used on exactly three surfaces: prayer countdown, tasbih counter, Hifz mastery figure.

| Token | Size | Weight | LH | LS | Usage |
| --- | --- | --- | --- | --- | --- |
| display.large | 57 | 400 | 1.12 / 1.45 | -0.25 | Prayer countdown |
| display.medium | 45 | 400 | 1.16 / 1.45 | 0 | Tasbih counter |
| display.small | 36 | 400 | 1.22 / 1.48 | 0 | Mastery percentage, khatmah progress |

Display weight is 400, not bold. At 57px regular already carries presence; bolding makes the screen shout.

### 9.2 Headline

| Token | Size | Weight | LH | LS | Usage |
| --- | --- | --- | --- | --- | --- |
| headline.large | 32 | 500 | 1.25 / 1.52 | 0 | Surah name header |
| headline.medium | 28 | 500 | 1.28 / 1.55 | 0 | Onboarding headings |
| headline.small | 24 | 500 | 1.33 / 1.55 | 0 | Empty states, dialog titles |

### 9.3 Title

| Token | Size | Weight | LH | LS | Usage |
| --- | --- | --- | --- | --- | --- |
| title.large | 22 | 500 | 1.27 / 1.55 | 0 | App bar title |
| title.medium | 16 | 600 | 1.50 / 1.70 | +0.15 | List tile title, card title |
| title.small | 14 | 600 | 1.43 / 1.65 | +0.10 | Compact list title, sheet header |

### 9.4 Body

| Token | Size | Weight | LH | LS | Usage |
| --- | --- | --- | --- | --- | --- |
| body.large | 16 | 400 | 1.50 / 1.70 | +0.50 | Primary UI body copy |
| body.medium | 14 | 400 | 1.43 / 1.70 | +0.25 | Secondary body, list subtitles |
| body.small | 12 | 400 | 1.33 / 1.65 | +0.40 | Dense supporting text |

### 9.5 Label

| Token | Size | Weight | LH | LS | Usage |
| --- | --- | --- | --- | --- | --- |
| label.large | 14 | 500 | 1.43 / 1.65 | +0.10 | Tab labels, chips, nav labels |
| label.medium | 12 | 500 | 1.33 / 1.60 | +0.50 | Badges, small chips |
| label.small | 11 | 500 | 1.45 / 1.60 | +0.50 | Overline, uppercase markers |

### 9.6 Caption

Not an M3 role. Added because metadata here carries real meaning: reciter names, calculation methods, hadith gradings, licence attributions.

| Token | Size | Weight | LH | LS | Usage |
| --- | --- | --- | --- | --- | --- |
| caption.default | 12 | 400 | 1.33 / 1.65 | +0.40 | Timestamps, counts, reciter names |
| caption.strong | 12 | 500 | 1.33 / 1.65 | +0.40 | Hadith grading, verification status |
| caption.mono | 12 | 400 | 1.33 / - | 0 | Trace IDs, version strings, tnum on |

### 9.7 Button

| Token | Size | Weight | LH | LS | Usage |
| --- | --- | --- | --- | --- | --- |
| button.large | 16 | 600 | 1.25 / 1.50 | +0.10 | Primary CTA, filled buttons |
| button.medium | 14 | 600 | 1.43 / 1.55 | +0.10 | Standard buttons, dialog actions |
| button.small | 13 | 600 | 1.38 / 1.55 | +0.20 | Inline text buttons |

Button weight is 600 throughout. In Arabic it degrades to 500 where no 600 master exists, never to 700.

### 9.8 Reading styles (outside TextTheme)

These are not UI roles and are user-adjustable, which no TextTheme role is.

| Token | Default | User range | Weight | LH | Face |
| --- | --- | --- | --- | --- | --- |
| reading.mushaf | 26 | 18-48 | 400 | 2.00 min | KFGQPC Uthmanic Hafs |
| reading.translation | 17 | 14-32 | 400 | 1.70 | Literata / Noto Naskh |
| reading.transliteration | 15 | 13-28 | 400 italic | 1.60 | Literata italic, Latin only |
| reading.tafsir | 16 | 14-30 | 400 | 1.75 | Literata / Noto Naskh |
| reading.verseNumber | 15 | scales with mushaf | 400 | 1.00 | Uthmanic Hafs, U+06DD |
| reading.footnote | 13 | scales | 400 | 1.55 | Literata / Noto Naskh |

Arabic and translation sizes are independent controls. Bilal reads Arabic-only at 40; Sara reads English at 20 with small Arabic. One slider serves neither, and one slider is what every competitor ships.

---

## 10. Numerals

| Context | Treatment |
| --- | --- |
| Prayer times, countdowns, durations | Inter with tnum, mandatory |
| Verse numbers in the mushaf | U+06DD end-of-ayah ornament from the Quranic font, never a Latin digit in a circle |
| Verse numbers in translation view | Inter tabular, superscript via baseline shift |
| Counters and statistics | Inter tnum |
| Arabic-Indic numerals | User preference via the locl feature. Off by default even in Arabic locales; preference splits and most users expect Western digits in UI chrome. |

---

## 11. Accessibility

| Requirement | Implementation |
| --- | --- |
| Scaling to 200 percent | MediaQuery.textScalerOf(context), never clamped |
| Minimum rendered size | 11sp at 1.0x, so 22sp at 2.0x |
| No fixed-height containers around text | Lint: SizedBox(height:) wrapping a Text fails review |
| Line clamping | maxLines permitted on titles only, never on body or reading content |
| Screen reader | Arabic text carries explicit Locale('ar') so TTS avoids English phonetics |
| Golden coverage | Every component at 1.0x, 1.5x, 2.0x, 3.0x by LTR/RTL by 3 themes |

We do not clamp text scale. Clamping silently overrides a setting the user deliberately enabled. Layouts reflow instead, which is why title.medium is 16/600 rather than 18/500.

---

## 12. Flutter implementation

### 12.1 Font registry

```dart
enum QScript { latin, arabic, quranic }

@immutable
class QFontFace {
  const QFontFace({
    required this.family,
    required this.opticalScale,
    required this.minHeight,
    required this.availableWeights,
  });

  final String family;
  final double opticalScale;
  final double minHeight;
  final Set<int> availableWeights;

  /// Degrades a requested weight to the nearest real master.
  /// Never upgrades to 700 - over-emphasis is worse than under.
  FontWeight resolveWeight(int requested) {
    if (availableWeights.contains(requested)) {
      return FontWeight.values[(requested ~/ 100) - 1];
    }
    final lower = availableWeights.where((w) => w < requested);
    final chosen = lower.isEmpty
        ? availableWeights.reduce(math.min)
        : lower.reduce(math.max);
    return FontWeight.values[(chosen ~/ 100) - 1];
  }
}

class QFonts {
  static const interUi = QFontFace(
    family: 'Inter',
    opticalScale: 1.00,
    minHeight: 1.30,
    availableWeights: {400, 500, 600, 700},
  );

  static const plexArabicUi = QFontFace(
    family: 'IBMPlexSansArabic',
    opticalScale: 1.10,
    minHeight: 1.70,
    availableWeights: {400, 500, 600, 700},
  );

  static const literataReading = QFontFace(
    family: 'Literata',
    opticalScale: 1.00,
    minHeight: 1.60,
    availableWeights: {400, 500, 600, 700},
  );

  static const notoNaskhReading = QFontFace(
    family: 'NotoNaskhArabic',
    opticalScale: 1.15,
    minHeight: 1.80,
    availableWeights: {400, 700},
  );

  static const uthmanicHafs = QFontFace(
    family: 'KFGQPCUthmanicHafs',
    opticalScale: 1.00,
    minHeight: 2.00,
    availableWeights: {400},
  );
}
```

### 12.2 Style resolver

Every style is built through this one function. Nothing constructs a TextStyle by hand.

```dart
TextStyle qStyle({
  required QFontFace face,
  required double size,
  required int weight,
  required double height,
  double letterSpacing = 0,
  FontStyle fontStyle = FontStyle.normal,
  List<FontFeature>? features,
}) {
  final isArabicScript =
      face == QFonts.plexArabicUi ||
      face == QFonts.notoNaskhReading ||
      face == QFonts.uthmanicHafs;

  return TextStyle(
    fontFamily: face.family,
    fontSize: size * face.opticalScale,
    fontWeight: face.resolveWeight(weight),
    height: math.max(height, face.minHeight),
    // Positive tracking breaks Arabic cursive joins. Always zero.
    letterSpacing: isArabicScript ? 0 : letterSpacing,
    // Arabic must never be synthetically italicised.
    fontStyle: isArabicScript ? FontStyle.normal : fontStyle,
    leadingDistribution: TextLeadingDistribution.even,
    fontFeatures: features,
  );
}
```

### 12.3 TextTheme

```dart
TextTheme buildTextTheme({required bool isArabicLocale}) {
  final ui = isArabicLocale ? QFonts.plexArabicUi : QFonts.interUi;
  final lh = isArabicLocale;

  return TextTheme(
    displayLarge: qStyle(
      face: ui, size: 57, weight: 400,
      height: lh ? 1.45 : 1.12, letterSpacing: -0.25,
      features: const [FontFeature.tabularFigures()],
    ),
    displayMedium: qStyle(
      face: ui, size: 45, weight: 400, height: lh ? 1.45 : 1.16,
      features: const [FontFeature.tabularFigures()],
    ),
    displaySmall: qStyle(
      face: ui, size: 36, weight: 400, height: lh ? 1.48 : 1.22,
      features: const [FontFeature.tabularFigures()],
    ),

    headlineLarge:  qStyle(face: ui, size: 32, weight: 500, height: lh ? 1.52 : 1.25),
    headlineMedium: qStyle(face: ui, size: 28, weight: 500, height: lh ? 1.55 : 1.28),
    headlineSmall:  qStyle(face: ui, size: 24, weight: 500, height: lh ? 1.55 : 1.33),

    titleLarge:  qStyle(face: ui, size: 22, weight: 500, height: lh ? 1.55 : 1.27),
    titleMedium: qStyle(face: ui, size: 16, weight: 600, height: lh ? 1.70 : 1.50,
                        letterSpacing: 0.15),
    titleSmall:  qStyle(face: ui, size: 14, weight: 600, height: lh ? 1.65 : 1.43,
                        letterSpacing: 0.10),

    bodyLarge:  qStyle(face: ui, size: 16, weight: 400, height: lh ? 1.70 : 1.50,
                       letterSpacing: 0.50),
    bodyMedium: qStyle(face: ui, size: 14, weight: 400, height: lh ? 1.70 : 1.43,
                       letterSpacing: 0.25),
    bodySmall:  qStyle(face: ui, size: 12, weight: 400, height: lh ? 1.65 : 1.33,
                       letterSpacing: 0.40),

    labelLarge:  qStyle(face: ui, size: 14, weight: 500, height: lh ? 1.65 : 1.43,
                        letterSpacing: 0.10),
    labelMedium: qStyle(face: ui, size: 12, weight: 500, height: lh ? 1.60 : 1.33,
                        letterSpacing: 0.50),
    labelSmall:  qStyle(face: ui, size: 11, weight: 500, height: lh ? 1.60 : 1.45,
                        letterSpacing: 0.50),
  );
}
```

### 12.4 Reading, caption and button extension

```dart
@immutable
class QTypography extends ThemeExtension<QTypography> {
  const QTypography({
    required this.mushaf,
    required this.translation,
    required this.transliteration,
    required this.tafsir,
    required this.verseNumber,
    required this.footnote,
    required this.captionDefault,
    required this.captionStrong,
    required this.captionMono,
    required this.buttonLarge,
    required this.buttonMedium,
    required this.buttonSmall,
  });

  final TextStyle mushaf, translation, transliteration, tafsir,
      verseNumber, footnote, captionDefault, captionStrong, captionMono,
      buttonLarge, buttonMedium, buttonSmall;

  /// Reading sizes come from user preferences, not from a constant.
  factory QTypography.resolve({
    required bool isArabicLocale,
    required double mushafSize,
    required double translationSize,
  }) {
    final ui = isArabicLocale ? QFonts.plexArabicUi : QFonts.interUi;
    final reading =
        isArabicLocale ? QFonts.notoNaskhReading : QFonts.literataReading;

    return QTypography(
      mushaf: qStyle(
        face: QFonts.uthmanicHafs,
        size: mushafSize, weight: 400, height: 2.00,
      ),
      translation: qStyle(
        face: reading, size: translationSize, weight: 400, height: 1.70,
      ),
      transliteration: qStyle(
        face: QFonts.literataReading,
        size: translationSize - 2, weight: 400, height: 1.60,
        fontStyle: FontStyle.italic,
      ),
      tafsir: qStyle(
        face: reading, size: translationSize - 1, weight: 400, height: 1.75,
      ),
      verseNumber: qStyle(
        face: QFonts.uthmanicHafs,
        size: mushafSize * 0.58, weight: 400, height: 1.00,
      ),
      footnote: qStyle(
        face: reading, size: translationSize - 4, weight: 400, height: 1.55,
      ),
      captionDefault: qStyle(
        face: ui, size: 12, weight: 400,
        height: isArabicLocale ? 1.65 : 1.33, letterSpacing: 0.40,
      ),
      captionStrong: qStyle(
        face: ui, size: 12, weight: 500,
        height: isArabicLocale ? 1.65 : 1.33, letterSpacing: 0.40,
      ),
      captionMono: qStyle(
        face: QFonts.interUi, size: 12, weight: 400, height: 1.33,
        features: const [FontFeature.tabularFigures()],
      ),
      buttonLarge: qStyle(
        face: ui, size: 16, weight: 600,
        height: isArabicLocale ? 1.50 : 1.25, letterSpacing: 0.10,
      ),
      buttonMedium: qStyle(
        face: ui, size: 14, weight: 600,
        height: isArabicLocale ? 1.55 : 1.43, letterSpacing: 0.10,
      ),
      buttonSmall: qStyle(
        face: ui, size: 13, weight: 600,
        height: isArabicLocale ? 1.55 : 1.38, letterSpacing: 0.20,
      ),
    );
  }
}
```

### 12.5 Mixed-script strut

A list where some rows are Arabic and some Latin will have uneven row heights unless a strut pins the line box.

```dart
StrutStyle qStrut(TextStyle style) => StrutStyle(
      fontFamily: style.fontFamily,
      fontSize: style.fontSize,
      height: style.height,
      leading: 0,
      forceStrutHeight: true,
      leadingDistribution: TextLeadingDistribution.even,
    );
```

Applied to every Text in a list or table context. Not applied in the reader, where the Arabic line must grow for diacritics.

### 12.6 Wiring

```dart
ThemeData buildTheme({
  required QThemeMode mode,
  required Locale locale,
  required ReadingPrefs prefs,
}) {
  final isArabic = locale.languageCode == 'ar';

  return ThemeData(
    useMaterial3: true,
    colorScheme: schemeFor(mode),
    textTheme: buildTextTheme(isArabicLocale: isArabic),
    extensions: [
      QTypography.resolve(
        isArabicLocale: isArabic,
        mushafSize: prefs.mushafSize,
        translationSize: prefs.translationSize,
      ),
    ],
  );
}
```

---

## 13. Bundle budget

| Asset | Delivery | Size |
| --- | --- | --- |
| Inter variable, Latin + Latin-Ext subset | Bundled | ~120 KB |
| IBM Plex Sans Arabic, 4 weights, subset | Bundled | ~280 KB |
| Literata variable, Latin subset | Bundled | ~180 KB |
| Noto Naskh Arabic, 2 weights | On-demand | ~340 KB |
| KFGQPC Uthmanic Hafs | Content pack | ~1.1 MB |
| Bundled total | | ~580 KB |

Against an 80 MB app-size budget this is comfortable.

---

## 14. Verification

| Check | Frequency | Blocks |
| --- | --- | --- |
| No TextStyle constructed outside qStyle() | Every PR | Merge |
| No non-zero letterSpacing resolvable to an Arabic face | Every PR | Merge |
| No italic on an Arabic face | Every PR | Merge |
| No fontWeight outside {400, 500, 600, 700} | Every PR | Merge |
| Arabic height below 1.7 or Quranic below 2.0 | Every PR | Merge |
| Goldens at 1.0x, 1.5x, 2.0x, 3.0x by LTR/RTL by 3 themes | Component PR | Merge |
| Mushaf 604-page golden diff | Renderer PR | Merge, release |
| Font checksum matches content pack manifest | Content release | Release |

---

## 15. Open positions

1. kArabicScale = 1.10 will look like a magic number in review. It is the correct fix for a real problem, but it should be re-tuned with native Arabic readers during M4 rather than treated as settled.
2. Four families is one more than usually defensible. Dropping Literata saves 180 KB. Keep it: translation is the second-most-read text and a serif measurably outperforms a sans over 45-minute sessions. First thing to cut under bundle pressure.
3. Noto Naskh Arabic having no 500 or 600 masters creates a permanent emphasis asymmetry between English and Arabic list titles. Full-weight naskh families are commercial. Accept the asymmetry, but show it in mockups before it appears in the build.
4. Not clamping text scale will cost layout bugs. Budget for them in M8 rather than discovering them there.
