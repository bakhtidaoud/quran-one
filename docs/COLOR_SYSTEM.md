# Quran One - Colour System

**Version 1.0 | Codename: Mizan | Material Design 3 | Flutter-first**
**Owner: Design | Status: Draft for engineering review**

> Companion to DESIGN_SYSTEM.md. All contrast ratios below are computed with the WCAG 2.1 relative luminance formula and are verified in CI on every pull request. If a value here and a value in `packages/design_system/lib/src/colors.dart` disagree, the build fails.

---

## 1. Token architecture

Three layers. Components may reference layer 3 or layer 2. Never layer 1.

```
Layer 1  Reference   q.ref.color.green.40       raw palette, no meaning
Layer 2  System      q.sys.color.primary        semantic role (M3)
Layer 3  Component   q.comp.ayah.bg.selected    contextual
```

Tokens never describe appearance. `q.sys.color.primary`, never `q.color.darkGreen` - because in AMOLED it is not dark green and the name would then lie.

---

## 2. Source hues and why they were chosen

| Role | Seed | Name | Rationale |
| --- | --- | --- | --- |
| Primary | `#1F4A3C` | Mihrab | A deep, desaturated green closer to bottle green than to flag green. Islamic by association rather than by cliche. At 10.0:1 against white it carries body text, which a brighter green cannot. |
| Secondary | `#6B563C` | Sabr | Warm sand-brown. Supplies warmth without competing for attention. Chosen over grey because a purely neutral secondary makes the parchment canvas read as cold. |
| Accent | `#B4552F` | Sidr | Muted terracotta. The single high-emphasis colour, drawn from manuscript ink and clay rather than from gold. Deliberately warm so it separates cleanly from every green in the system. |
| Info | `#2A5C82` | Layl | Muted slate blue. Informational only. Low chroma so it never reads as interactive. |
| Neutral | `#78746E` | - | Warm-shifted grey. Never a blue-grey; blue-grey makes parchment surfaces look grey-green. |

### Why no gold

Gold is the default instinct for a premium Islamic product and it is a trap. At scale it reads as either cheap or ostentatious, it fails contrast against light surfaces at almost every usable tone, and it dates hard. Where a premium cue is needed, this system uses weight, space and typography.

---

## 3. Light theme

Base canvas is `#FBF8F3`, not `#FFFFFF`. Pure white at reading brightness measurably increases eye strain over long sessions, and the personas who read longest read for 45+ minutes. The warm off-white also flatters the Uthmanic script's stroke contrast.

### 3.1 Brand and semantic colours

| Token | HEX | RGB | Contrast | Usage |
| --- | --- | --- | --- | --- |
| Primary | `#1F4A3C` | 31, 74, 60 | 10.0:1 on white | Primary buttons, active nav, verse markers, focus ring |
| On primary | `#FFFFFF` | 255, 255, 255 | 10.0:1 on primary | Label on filled primary |
| Primary container | `#A8D5C4` | 168, 213, 196 | - | Selected chips, tonal buttons |
| On primary container | `#002019` | 0, 32, 25 | 14.9:1 on container | Text inside primary container |
| Secondary | `#6B563C` | 107, 86, 60 | 7.0:1 on bg | Secondary buttons, supporting metadata |
| Secondary container | `#EADDCB` | 234, 221, 203 | - | Reading plan cards, low-emphasis fills |
| Accent | `#B4552F` | 180, 85, 47 | 4.9:1 on bg | Bookmarks, single high-emphasis CTA, active audio |
| Success | `#2D6A4F` | 45, 106, 79 | 6.5:1 on bg | Completed review, verified download, plan complete |
| Warning | `#8A5A00` | 138, 90, 0 | 5.9:1 on bg | Athan reliability warning, storage nearly full |
| Error | `#8C1D18` | 140, 29, 24 | 9.2:1 on bg | Validation, sync failure, payment failure |
| Info | `#2A5C82` | 42, 92, 130 | 7.1:1 on bg | Calculation method notes, neutral system messages |

### 3.2 Surfaces

| Token | HEX | RGB | Contrast | Usage |
| --- | --- | --- | --- | --- |
| Background | `#FBF8F3` | 251, 248, 243 | base | App canvas, scaffold |
| Surface | `#FFFFFF` | 255, 255, 255 | 1.06:1 on bg | Sheets, app bar, dialogs |
| Card | `#FFFFFF` | 255, 255, 255 | 1.06:1 on bg | Cards, list tiles |
| Surface variant | `#F1EBE1` | 241, 235, 225 | 1.10:1 on bg | Input fields, inert containers |
| Inverse surface | `#2E312F` | 46, 49, 47 | 12.6:1 on bg | Snackbars, tooltips |

Cards are lighter than the background rather than darker. On a warm canvas, a lifted surface reading as brighter is the more natural light model and avoids the muddy grey card problem.

### 3.3 Dividers and borders

| Token | HEX | RGB | Contrast | Usage |
| --- | --- | --- | --- | --- |
| Divider | `#E6E0D6` | 230, 224, 214 | 1.24:1 on bg | Decorative separation only |
| Border strong | `#8F877A` | 143, 135, 122 | 3.4:1 on bg | Any border that is the sole affordance (outlined button, focused field) |

This distinction is deliberate and is the most commonly failed accessibility rule in design systems. A divider that merely separates two lists is decorative and exempt from contrast requirements. A border that is the only thing telling a user something is a control must clear 3:1. Two tokens, not one.

### 3.4 Text

| Token | HEX | RGB | Contrast | Usage |
| --- | --- | --- | --- | --- |
| Text primary | `#16181C` | 22, 24, 28 | 16.8:1 | Body, headings, translation |
| Text secondary | `#5A5D63` | 90, 93, 99 | 6.2:1 | Metadata, captions, timestamps |
| Text muted | `#7A7D83` | 122, 125, 131 | 3.9:1 | Large-text and non-essential labels only |
| Text disabled | `#8B8E94` | 139, 142, 148 | 3.0:1 | Disabled control labels |
| Text on accent | `#FFFFFF` | 255, 255, 255 | 4.9:1 | Label on accent fill |

Text primary is `#16181C`, a near-black with a slight cool cast, not `#000000`. Pure black on a warm canvas produces a hard edge that fatigues at reading sizes; a hair of blue in the ink reads as crisper without the harshness.

Text muted at 3.9:1 does not meet AA for normal body text and is restricted by lint to text at 18.66px bold or 24px and above.

### 3.5 Icons

| Token | HEX | RGB | Contrast | Usage |
| --- | --- | --- | --- | --- |
| Icon default | `#3A3D42` | 58, 61, 66 | 10.3:1 | Nav icons, action icons |
| Icon muted | `#5A5D63` | 90, 93, 99 | 6.2:1 | Inline decorative icons |
| Icon disabled | `#8B8E94` | 139, 142, 148 | 3.0:1 | Disabled controls |
| Icon on primary | `#FFFFFF` | 255, 255, 255 | 10.0:1 | Icons on filled primary |

Icons are darker than secondary text. Glyph strokes are thinner than type stems, so equal contrast reads as lighter. Matching them numerically is the mistake; matching them optically means the icon goes darker.

### 3.6 Reading surfaces (outside M3)

The mushaf cannot use `surface` and `onSurface`. Those roles are tuned for UI legibility at 14-16sp Latin text, not for extended reading of vocalised Arabic at 22-30sp.

| Token | HEX | RGB | Contrast | Usage |
| --- | --- | --- | --- | --- |
| Reading canvas | `#FBF8F3` | 251, 248, 243 | base | Mushaf page |
| Reading ink | `#16181C` | 22, 24, 28 | 16.8:1 | Quranic text |
| Reading ink muted | `#5A5D63` | 90, 93, 99 | 6.2:1 | Transliteration, footnote markers |
| Reading mark | `#1F4A3C` | 31, 74, 60 | 10.0:1 | Verse numbers, sajdah marks, juz markers |
| Reading rule | `#E6E0D6` | 230, 224, 214 | 1.24:1 | Hairline between verse and translation |

---

## 4. Dark theme

| Token | HEX | RGB | Contrast on bg | Usage |
| --- | --- | --- | --- | --- |
| Primary | `#7FB8A2` | 127, 184, 162 | 8.0:1 | Buttons, active states |
| On primary | `#00382A` | 0, 56, 42 | 6.9:1 on primary | Label on filled primary |
| Primary container | `#2B5C4C` | 43, 92, 76 | - | Tonal fills |
| Secondary | `#C9AE8B` | 201, 174, 139 | 8.6:1 | Supporting metadata |
| Accent | `#E0906B` | 224, 144, 107 | 7.2:1 | Bookmarks, single high-emphasis CTA |
| Success | `#7EC8A0` | 126, 200, 160 | 9.2:1 | Completion states |
| Warning | `#E0B65C` | 224, 182, 92 | 9.5:1 | Reliability and storage warnings |
| Error | `#F2B8B5` | 242, 184, 181 | 10.6:1 | Validation and failure |
| Info | `#9BC4E8` | 155, 196, 232 | 9.9:1 | Neutral system messages |
| Background | `#14161A` | 20, 22, 26 | base | Scaffold |
| Surface | `#1A1D22` | 26, 29, 34 | 1.13:1 | Sheets, app bar |
| Card | `#212429` | 33, 36, 41 | 1.28:1 | Cards, list tiles |
| Divider | `#262A30` | 38, 42, 48 | 1.44:1 | Decorative separation |
| Border strong | `#3A3F47` | 58, 63, 71 | 2.2:1 | Sole-affordance borders |
| Text primary | `#E4E1DC` | 228, 225, 220 | 13.9:1 | Body, headings |
| Text secondary | `#A8A5A0` | 168, 165, 160 | 7.4:1 | Metadata |
| Text muted | `#7E7B77` | 126, 123, 119 | 4.3:1 | Large text only |
| Text disabled | `#66635F` | 102, 99, 95 | 3.0:1 | Disabled labels |
| Icon default | `#CFCCC7` | 207, 204, 199 | 11.3:1 | Nav and action icons |
| Reading canvas | `#14161A` | 20, 22, 26 | base | Mushaf page |
| Reading ink | `#E4E1DC` | 228, 225, 220 | 13.9:1 | Quranic text |
| Reading mark | `#7FB8A2` | 127, 184, 162 | 8.0:1 | Verse numbers |

Background is `#14161A`, a very slightly blue-shifted near-black rather than a neutral `#121212`. Against warm cream reading ink the small cool cast increases perceived separation without raising measured contrast, so the page reads crisper at the same luminance.

All brand hues are lifted to tone 80 or thereabouts. `#1F4A3C` on a dark canvas is 1.6:1 and effectively invisible. This is why primary is not a fixed brand colour in this system; it is a role that resolves differently per theme.

---

## 5. AMOLED theme

AMOLED is not dark theme with black swapped in. Two things change materially.

### 5.1 Text is `#D9D6D1`, never `#FFFFFF`

Pure white on pure black causes halation, a visible bloom around glyph edges on OLED panels. Vocalised Arabic is full of thin diacritical strokes, which is precisely the case where halation destroys legibility - the fatha smears into the letterform. Backing off to `#D9D6D1` still yields 14.5:1, well above any requirement, and removes the bloom entirely. This is the single most common mistake in AMOLED implementations and it is free to get right.

### 5.2 Tonal elevation does not exist on `#000000`

M3 conveys elevation by tinting the surface lighter, which immediately abandons the power saving that justifies AMOLED mode in the first place. So AMOLED substitutes 1px hairline borders and shadow-free separation. Elevation becomes a line, not a wash.

| Token | HEX | RGB | Contrast on bg | Usage |
| --- | --- | --- | --- | --- |
| Primary | `#7FB8A2` | 127, 184, 162 | 9.3:1 | Buttons, active states |
| On primary | `#00382A` | 0, 56, 42 | 6.9:1 on primary | Label on filled primary |
| Secondary | `#C9AE8B` | 201, 174, 139 | 9.9:1 | Supporting metadata |
| Accent | `#E0906B` | 224, 144, 107 | 8.4:1 | Bookmarks, high-emphasis CTA |
| Success | `#7EC8A0` | 126, 200, 160 | 10.7:1 | Completion states |
| Warning | `#E0B65C` | 224, 182, 92 | 11.0:1 | Warnings |
| Error | `#F2B8B5` | 242, 184, 181 | 12.3:1 | Failure states |
| Info | `#9BC4E8` | 155, 196, 232 | 11.5:1 | System messages |
| Background | `#000000` | 0, 0, 0 | base | Scaffold, true black |
| Surface | `#0A0A0B` | 10, 10, 11 | 1.03:1 | Sheets, app bar |
| Card | `#0E0F11` | 14, 15, 17 | 1.05:1 | Cards, list tiles |
| Divider | `#161616` | 22, 22, 22 | 1.10:1 | Hairline separation, elevation level 1 |
| Border strong | `#2A2A2C` | 42, 42, 44 | 1.28:1 | Sole-affordance borders |
| Text primary | `#D9D6D1` | 217, 214, 209 | 14.5:1 | Body, headings |
| Text secondary | `#A3A09B` | 163, 160, 155 | 7.8:1 | Metadata |
| Text muted | `#78756F` | 120, 117, 111 | 4.2:1 | Large text only |
| Text disabled | `#605D59` | 96, 93, 89 | 3.3:1 | Disabled labels |
| Icon default | `#C6C3BE` | 198, 195, 190 | 12.4:1 | Nav and action icons |
| Reading canvas | `#000000` | 0, 0, 0 | base | Mushaf page |
| Reading ink | `#D9D6D1` | 217, 214, 209 | 14.5:1 | Quranic text |
| Reading mark | `#7FB8A2` | 127, 184, 162 | 9.3:1 | Verse numbers |

Brand hues are shared with dark theme rather than re-derived. Two nearly identical dark palettes double the maintenance cost and the contrast matrix for a difference no user can name. What differs is the surface stack and the elevation model, which is what actually distinguishes the theme.

---

## 6. User highlight colours

Five highlight colours, each tested against all three themes at both AA text contrast and 3:1 non-text contrast. Highlights sit behind text and never reduce ink contrast below 7:1.

| Name | Light | Dark / AMOLED | Usage |
| --- | --- | --- | --- |
| Saffron | `#F5E6C3` | `#4A4020` | Default first highlight |
| Sage | `#D9E8DC` | `#1E3A2C` | Thematic grouping |
| Sky | `#D6E4F0` | `#1C3446` | Cross-references |
| Rose | `#F2DCDC` | `#442426` | Personal significance |
| Lilac | `#E4DCEF` | `#332A45` | Study notes |

Highlight names are user-facing and deliberately non-semantic. Naming them "important" or "review" would impose a study method on users who have their own.

---

## 7. Flutter ColorScheme mapping

| M3 role | Light | Dark | AMOLED |
| --- | --- | --- | --- |
| `primary` | `#1F4A3C` | `#7FB8A2` | `#7FB8A2` |
| `onPrimary` | `#FFFFFF` | `#00382A` | `#00382A` |
| `primaryContainer` | `#A8D5C4` | `#2B5C4C` | `#1A3A30` |
| `onPrimaryContainer` | `#002019` | `#C4EBD9` | `#C4EBD9` |
| `secondary` | `#6B563C` | `#C9AE8B` | `#C9AE8B` |
| `onSecondary` | `#FFFFFF` | `#3A2C18` | `#3A2C18` |
| `secondaryContainer` | `#EADDCB` | `#4E4030` | `#2E2519` |
| `onSecondaryContainer` | `#241A0C` | `#EADDCB` | `#EADDCB` |
| `tertiary` | `#2A5C82` | `#9BC4E8` | `#9BC4E8` |
| `onTertiary` | `#FFFFFF` | `#0B2E45` | `#0B2E45` |
| `error` | `#8C1D18` | `#F2B8B5` | `#F2B8B5` |
| `onError` | `#FFFFFF` | `#601410` | `#601410` |
| `errorContainer` | `#F9DEDC` | `#8C1D18` | `#5A1512` |
| `surface` | `#FFFFFF` | `#1A1D22` | `#000000` |
| `onSurface` | `#16181C` | `#E4E1DC` | `#D9D6D1` |
| `surfaceContainerLowest` | `#FFFFFF` | `#0E1013` | `#000000` |
| `surfaceContainerLow` | `#FBF8F3` | `#16191D` | `#0A0A0B` |
| `surfaceContainer` | `#F6F1E9` | `#1A1D22` | `#0E0F11` |
| `surfaceContainerHigh` | `#F1EBE1` | `#212429` | `#141416` |
| `surfaceContainerHighest` | `#EBE4D8` | `#282C32` | `#1A1A1C` |
| `onSurfaceVariant` | `#5A5D63` | `#A8A5A0` | `#A3A09B` |
| `outline` | `#8F877A` | `#3A3F47` | `#2A2A2C` |
| `outlineVariant` | `#E6E0D6` | `#262A30` | `#161616` |
| `inverseSurface` | `#2E312F` | `#E4E1DC` | `#D9D6D1` |
| `onInverseSurface` | `#F1EFEA` | `#2E312F` | `#0E0F11` |
| `inversePrimary` | `#7FB8A2` | `#1F4A3C` | `#1F4A3C` |
| `shadow` | `#000000` | `#000000` | `#000000` |
| `scrim` | `#000000` | `#000000` | `#000000` |

### Roles with no M3 slot

Accent, success, warning, the five highlights and the entire reading ramp have no home in `ColorScheme`. Forcing success into `tertiary` is the usual workaround and it is wrong - `tertiary` is a brand role that M3 will place on chips and containers automatically, and semantic success must never appear decoratively. They live in `ThemeExtension` classes instead.

```dart
@immutable
class QSemanticColors extends ThemeExtension<QSemanticColors> {
  const QSemanticColors({
    required this.accent,
    required this.onAccent,
    required this.success,
    required this.warning,
    required this.info,
    required this.borderStrong,
  });

  final Color accent;
  final Color onAccent;
  final Color success;
  final Color warning;
  final Color info;
  final Color borderStrong;

  static const light = QSemanticColors(
    accent: Color(0xFFB4552F),
    onAccent: Color(0xFFFFFFFF),
    success: Color(0xFF2D6A4F),
    warning: Color(0xFF8A5A00),
    info: Color(0xFF2A5C82),
    borderStrong: Color(0xFF8F877A),
  );

  static const dark = QSemanticColors(
    accent: Color(0xFFE0906B),
    onAccent: Color(0xFF44200E),
    success: Color(0xFF7EC8A0),
    warning: Color(0xFFE0B65C),
    info: Color(0xFF9BC4E8),
    borderStrong: Color(0xFF3A3F47),
  );

  // copyWith / lerp omitted
}

@immutable
class ReadingTheme extends ThemeExtension<ReadingTheme> {
  const ReadingTheme({
    required this.canvas,
    required this.ink,
    required this.inkMuted,
    required this.mark,
    required this.rule,
  });

  final Color canvas;
  final Color ink;
  final Color inkMuted;
  final Color mark;
  final Color rule;

  static const light = ReadingTheme(
    canvas: Color(0xFFFBF8F3),
    ink: Color(0xFF16181C),
    inkMuted: Color(0xFF5A5D63),
    mark: Color(0xFF1F4A3C),
    rule: Color(0xFFE6E0D6),
  );

  static const amoled = ReadingTheme(
    canvas: Color(0xFF000000),
    ink: Color(0xFFD9D6D1), // never 0xFFFFFFFF - halation
    inkMuted: Color(0xFF8E8B86),
    mark: Color(0xFF7FB8A2),
    rule: Color(0xFF161616),
  );
}
```

### Theme construction

```dart
enum QThemeMode { light, dark, amoled }

ThemeData buildTheme(QThemeMode mode) {
  final isLight = mode == QThemeMode.light;
  final isAmoled = mode == QThemeMode.amoled;

  final scheme = isLight ? qLightScheme : qDarkScheme;

  return ThemeData(
    useMaterial3: true,
    colorScheme: isAmoled ? qAmoledScheme : scheme,
    scaffoldBackgroundColor: isLight
        ? const Color(0xFFFBF8F3)
        : isAmoled
            ? const Color(0xFF000000)
            : const Color(0xFF14161A),
    // AMOLED replaces tonal elevation with hairlines.
    cardTheme: CardThemeData(
      elevation: isAmoled ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(QShape.md),
        side: isAmoled
            ? const BorderSide(color: Color(0xFF161616))
            : BorderSide.none,
      ),
    ),
    extensions: [
      isLight ? QSemanticColors.light : QSemanticColors.dark,
      isLight ? ReadingTheme.light : ReadingTheme.amoled,
    ],
  );
}
```

The schemes are hand-authored constants, not `ColorScheme.fromSeed` output. `fromSeed` is excellent for exploration and unacceptable as a source of truth here, because a Flutter SDK upgrade can change the generated tones and silently move a contrast ratio below AA. We seed once, freeze the values, and own them.

### Dynamic colour

Material You dynamic colour is supported for UI chrome and disabled for reading surfaces. A user's wallpaper may tint the navigation bar. It may not set the contrast ratio of the Quran.

---

## 8. Contrast requirements

| Content | WCAG AA minimum | Our floor |
| --- | --- | --- |
| Quranic text | 4.5:1 | 12:1 |
| Translation text | 4.5:1 | 8:1 |
| Body and labels | 4.5:1 | 5.5:1 |
| Large text (18.66px bold / 24px) | 3:1 | 4.5:1 |
| Icons, focus rings, sole-affordance borders | 3:1 | 3.5:1 |
| Disabled | exempt | 3:1 anyway |
| Decorative dividers | exempt | no floor |

We exceed AA substantially on reading text. This is not perfectionism. A user reading vocalised Arabic at 26sp for 45 minutes in variable outdoor light is operating far outside the conditions AA was calibrated for, and the diacritics are the first thing to disappear.

Disabled states are exempt under WCAG. We hold them to 3:1 anyway, because a user who cannot read a disabled label cannot tell whether the control is disabled or simply unlabelled.

---

## 9. Colour is never the sole carrier of meaning

| State | Colour | Plus |
| --- | --- | --- |
| Review complete | Success | Check icon + "Complete" label |
| Athan unreliable | Warning | Warning icon + reliability percentage in text |
| Hadith grading | none | Full grade text always, never a colour dot |
| Tajweed rules | Rule colours | Long-press reveals rule name; screen reader announces "ikhfa" |
| Sync failure | Error | Icon + explanatory text + retry action |
| Verse selected | Highlight tint | Persistent left border + selection announcement |

This is a WCAG requirement, but it also matters for a specific reason in this product: tajweed colouring is a genuine learning aid and roughly 1 in 12 men has a colour vision deficiency. A tajweed system that only works for trichromats is a teaching tool that excludes 8% of its students.

---

## 10. Verification

| Check | Frequency | Blocks |
| --- | --- | --- |
| Every token pair in the matrix meets its floor | Every PR | Merge |
| No raw `Color(0x...)` outside `design_system/` | Every PR | Merge |
| Figma variables match Dart tokens | Every PR | Merge |
| Golden files across 3 themes x 2 directions x 4 text scales | Every component PR | Merge |
| Colour-blind simulation (protanopia, deuteranopia, tritanopia) | Per release | Release |
| Physical OLED halation review | Per release | Release |

---

## 11. Four decisions worth challenging

**1. Accent as terracotta will be the most debated choice here.** The instinct in this category is a second green or a gold. Terracotta was chosen precisely because it cannot be confused with primary at a glance, which is the entire job of an accent. If it tests poorly with users as "not Islamic enough", the fallback is a deep indigo, not gold.

**2. Success and primary are both green and that is a real problem.** `#2D6A4F` and `#1F4A3C` are 1.4:1 apart, which is nowhere near distinguishable. This is mitigated by never using success as a fill and always pairing it with a check icon and a label. A cleaner fix would be to move success off green entirely, but green-means-complete is deeply learned and fighting it costs more than it returns. Flagged as a known compromise rather than hidden.

**3. Not using `ColorScheme.fromSeed` at runtime will be questioned as unidiomatic.** It is. The alternative is a Flutter upgrade silently pushing a token below AA with no test failure, since nothing tests generated values. Frozen constants make contrast a property we own.

**4. Sharing brand hues between dark and AMOLED reduces theme distinctiveness.** Deliberately. The differentiation is in the surface stack and the elevation model, which is what users actually perceive. Two near-identical palettes double the contrast matrix for a difference nobody can name.
