# Quran One - Visual Language

Codename: Mizan. Companion to DESIGN_SYSTEM.md, COLOR_SYSTEM.md and TYPOGRAPHY_SYSTEM.md.

---

## 0. The decision that shapes everything else

No figurative illustration. No people, no faces, no animals, anywhere in this product.

This is not a stylistic preference. A significant portion of our users hold that depicting animate beings is impermissible, and the position varies by madhhab, region and family. Muslim Pro ships cartoon characters. Quranly ships an illustrated mascot. Both have made a theological choice on behalf of users who did not ask them to.

The correct move is not to pick a side. It is to build a visual system that has nothing to defend: geometric, architectural, abstract. The constraint also improves the work, because character illustration is the laziest way to fill an empty state.

The visual language is line, light and geometry. Never a figure.

---

## 1. Icon style

### 1.1 Construction

| Property | Value |
| --- | --- |
| Grid | 24 x 24dp keyline |
| Live area | 20 x 20dp (2dp padding all sides) |
| Stroke | 2dp, constant within a size tier |
| Terminals | Round cap, round join |
| Corner radius | 2dp minimum on interior corners |
| Style | Outlined by default. Filled reserved for selected state. |
| Optical alignment | Manual. Circles overshoot the keyline by 1dp, triangles by 1.5dp. |

### 1.2 Size tiers

Stroke does not scale linearly with size. A 2dp stroke at 40dp looks anaemic; the same ratio at 16dp turns to mush.

| Tier | Box | Stroke | Use |
| --- | --- | --- | --- |
| icon.xs | 16dp | 1.5dp | Inline with body.small, chips |
| icon.sm | 20dp | 1.75dp | Dense lists, text fields |
| icon.md | 24dp | 2dp | Default. Nav, actions, list leading. |
| icon.lg | 32dp | 2.25dp | Empty state marks, section heads |
| icon.xl | 40dp | 2.5dp | Onboarding, feature callouts |

### 1.3 Selected state

Not a colour swap. Outlined to filled, cross-fading over 150ms.

```
Rest      outlined, icon.default  (#3A3D42 light)
Selected  filled,   primary       (#1F4A3C light)
Disabled  outlined, icon.disabled (#8B8E94, 3:1)
```

Material Symbols exposes this as the FILL variable axis, so the transition is a continuous morph rather than a cross-fade between two glyphs. That is the strongest argument for the library choice in section 8.

### 1.4 The custom set

Material Symbols has about 3,300 icons and none of the nine we actually need.

| Icon | Construction rule |
| --- | --- |
| Mushaf | Open book, two facing pages, spine implied by a 2dp vertical. Never a closed book with a crescent on the cover. |
| Qibla | Compass ring plus directional needle. The Kaaba cube appears only in the Qibla feature. |
| Kaaba | Isometric cube, 2dp stroke, kiswa band as a single horizontal rule. No calligraphy at icon scale. |
| Athan | Sound waves from a minaret reduced to a rectangle plus dome. Architectural, not pictorial. |
| Tasbih | Seven beads on an arc. Seven, not 33 - 33 is illegible at 24dp. |
| Hifz | Book with an ascending progress arc above it. |
| Juz | A circle divided into 30 segments with one filled. |
| Sajdah | The traditional sajdah symbol, redrawn to system stroke weight. |
| Waqf | An open-topped vessel with a rising line. Not hands - hands are figurative. |

Custom icons are drawn on the same 24dp keyline grid at the same 2dp stroke, so they sit next to Material Symbols with no visible seam. That is the whole test.

### 1.5 Iconography restraint rules

1. The crescent is not a generic Islam icon. It is used nowhere in this product. It is a national and political symbol as much as a religious one, and it is the visual cliche of the category.
2. The Kaaba appears only in Qibla. Not on the home tab, not in the app icon, not as Hajj decoration.
3. No mosque icon for Home. Home is a house or a Quran.
4. No calligraphy as icon. Arabic script is content. At 24dp it becomes an illegible squiggle.

---

## 2. Illustration style

### 2.1 The system

Illustrations are oversized icons, not a separate visual world. Same 2dp stroke language, same round terminals, same geometric discipline, just larger with one flat tint.

| Property | Value |
| --- | --- |
| Canvas | 240 x 180dp (4:3), or 200 x 200 for square marks |
| Stroke | 2.5dp, heavier than icons because the canvas is larger |
| Palette | Two values only: outline stroke plus one flat tint at 8-12 percent opacity |
| Tint source | primary for neutral or positive, warning for degraded, info for informational |
| Perspective | Flat or single-point isometric. Never faux-3D. |
| Motifs | Geometric tiling, architectural arches, mushaf pages, light rays, orbital paths, star polygons |
| Never | People, faces, hands, animals, gradient meshes, drop shadows, mascots |

### 2.2 The motif library

Six base motifs, recombined. A closed set is what makes a system read as a system.

| Motif | Reads as | Used for |
| --- | --- | --- |
| Arch | Threshold, entry, structure | Onboarding, empty states |
| Open page | Content, reading | Reading empty states, bookmarks |
| Star polygon (8- and 12-point) | Order, geometry, tradition | Achievements, completion |
| Light rays | Guidance, clarity | Positive states, first run |
| Orbital path | Cycle, return, rhythm | Prayer, review, streaks |
| Broken line | Interruption, absence | Errors, offline |

The eight-point star (khatim) is the one traditional geometric form used, because it is genuinely universal across the Muslim world. Zellij, girih and muqarnas are all beautiful and all locally coded - a Moroccan reads zellij as home; an Indonesian reads it as foreign decoration.

### 2.3 Format

Static SVG. Not Lottie, not Rive. Reasoning in section 6.

Delivered via flutter_svg with a build-time optimisation pass, or compiled to .vec with vector_graphics for assets on the cold-start path.

---

## 3. Empty states

### 3.1 Anatomy

```
        [ Illustration - 200dp, tinted ]
                    32dp
              Headline (title.large)
                    8dp
        Body (body.medium, secondary) - max 2 lines
                    24dp
             [ Primary action ]
                    8dp
           [ Secondary action - text ]
```

### 3.2 Copy doctrine

Empty states are where guilt-based UX hides.

| Never | Always |
| --- | --- |
| You haven't read anything yet | Your reading will appear here |
| No bookmarks - start bookmarking! | Bookmarks you save appear here |
| You have 0 memorised verses | Verses you add to memorisation appear here |
| Don't leave this empty! | (nothing - an empty state is not a failure) |

An empty state describes what will be here, not what the user has failed to do. Passive-descriptive, never second-person-accusatory.

### 3.3 The catalogue

| Surface | Motif | Headline | Body |
| --- | --- | --- | --- |
| Bookmarks | Open page + star | Bookmarks appear here | Tap the bookmark icon on any verse to save it. |
| Notes | Open page + rule lines | Your notes appear here | Notes are encrypted and only readable on your devices. |
| Highlights | Open page + tint band | Highlights appear here | Select any verse to highlight it. |
| Hifz | Orbital path | Start memorising when you're ready | Add any surah or juz to begin. There's no schedule to fall behind on. |
| Reading history | Arch + light | Your reading appears here | We keep this on your device. |
| Search, no results | Broken line + page | No matches for "{query}" | Try a different spelling, or search by verse number. |
| Downloads | Arch + descending line | No downloads yet | Downloaded content works fully offline. |
| Prayer log | Orbital path | Your prayer log appears here | Logging is optional and private. |
| AI conversations | Light rays | Ask about a verse to begin | Answers always cite their sources. |

The Hifz copy is deliberate. "There's no schedule to fall behind on" is a direct rebuttal to Quranly's guilt mechanics, placed at the moment a user decides whether to start.

---

## 4. Error illustrations

### 4.1 Four categories

| Category | Motif | Tint | Tone |
| --- | --- | --- | --- |
| Offline / no connection | Arch with a broken span | info | Neutral. Offline is normal here. |
| Not found (404) | Open page, blank | info | Neutral. |
| Server / sync failure | Orbital path, one segment missing | warning | Apologetic, specific. |
| Permission / capability | Arch with a closed gate | warning | Explanatory, with the fix. |

### 4.2 Rules

1. No sad faces, no broken robots, no crying clouds. We do not do faces, and anthropomorphised failure is condescending.
2. Errors state the cause and the next action. "Couldn't reach the server" plus Retry. Never "Oops! Something went wrong."
3. Errors never blame the user.
4. The offline state is not an error state. P1 says offline is the default, not a degraded mode. Neutral tint, neutral copy.
5. A trace ID is always available in caption.mono, copyable on long-press. Support cannot debug "it didn't work."

### 4.3 What never gets an error illustration

Prayer times, Qibla and the mushaf cannot produce a network error, because they never call the server. If an error illustration appears on a worship surface that is an architecture bug, and there is a route-level test asserting it.

---

## 5. Loading

### 5.1 Three tiers by duration

| Duration | Treatment |
| --- | --- |
| Under 300ms | Nothing. No spinner, no skeleton, no flash. |
| 300ms to 3s | Skeleton matching the final layout |
| Over 3s | Determinate progress plus a sentence explaining what is happening |

A spinner that appears and disappears in 200ms reads as a glitch and makes the app feel slower than showing nothing.

### 5.2 Skeletons

- Shape-match the real content exactly: same heights, radii and spacing. A mismatched skeleton causes a reflow, which is worse than a spinner.
- Fill surfaceContainerHigh. Shimmer sweep at 1,400ms with easing.standard, direction follows text direction.
- Never skeleton Quranic text. Grey bars where an ayah will be is the wrong image. The reader shows the page frame and verse-number ornaments, then paints text.
- Reduced motion: shimmer becomes a static fill.

### 5.3 Determinate progress

Used for content-pack downloads, audio downloads, Hifz recompute and export.

```
Downloading Mishary Alafasy - Juz 1
[########________]  47%   82 MB of 174 MB
Continues in the background
```

Always: what, how far, how much, and whether the user can leave.

### 5.4 The reader never shows a full-screen loader

Page content paints progressively: frame, then verse ornaments, then glyphs.

---

## 6. Animation style, and why no Lottie

### 6.1 The recommendation

Illustrations are static vector. All motion is Flutter-native.

### 6.2 Why not Lottie or Rive

| Problem | Detail |
| --- | --- |
| RTL is impossible | A Lottie file is baked and cannot mirror. Every animation needs a hand-authored RTL twin. Disqualifying for an Arabic-first product. |
| Theming is impossible | Colours are baked. Three themes means three files each, or runtime colour-filter hacks. |
| Reduced motion not honoured | MediaQuery.disableAnimations does not reach inside a composition. |
| Bundle cost | 40-120 KB per animation plus runtime. Twelve pieces is about 1 MB of decoration. |
| Text scaling | Baked text does not scale with the accessibility setting. |
| Wrong centre of gravity | Lottie encourages bouncy mascot animation, already ruled out. |

Static SVG plus Flutter-native motion gives RTL mirroring, theming via colorFilter, automatic reduced-motion compliance, and about 8 KB per illustration.

### 6.3 Motion principles

| Token | ms |
| --- | --- |
| q.motion.instant | 50 |
| q.motion.short | 150 |
| q.motion.medium | 250 |
| q.motion.long | 400 |
| q.motion.page | 350 |

q.easing.standard cubic-bezier(0.2, 0, 0, 1) for on-screen movement; decelerate on entry, accelerate on exit.

No spring, no bounce, no overshoot, anywhere. Overshoot on Arabic text at 26sp is unpleasant, and playful physics is tonally wrong next to scripture.

### 6.4 Illustration motion

Illustrations may have exactly one of:

- A single element fading in 200ms after the rest, once, on first appearance
- A slow rotation on an orbital motif: 20s linear, opacity 0.4 or less

Both disabled under reduced motion. If it would catch the eye of someone reading nearby, it is wrong.

---

## 7. Micro-interactions

| Interaction | Visual | Duration | Haptic |
| --- | --- | --- | --- |
| Bookmark toggle | Outline to fill morph via FILL axis, 1.0 to 1.12 to 1.0 scale | 200ms | selectionClick |
| Verse select | Background tint fade plus persistent start-edge border | 150ms | selectionClick |
| Highlight applied | Tint wipes in from text start direction | 250ms | lightImpact |
| Tasbih tap | Number cross-fade only. The button does not move. | 120ms | mediumImpact |
| Tasbih target reached (33/99) | Ring completes, single pulse | 300ms | heavyImpact x1 |
| Page turn | Horizontal slide, no curl, no shadow sweep | 350ms | none |
| Audio play/pause | Play to pause glyph morph | 150ms | selectionClick |
| Verse audio active | Background cross-fade. Text never scales or moves. | 200ms | none |
| Hifz grade submitted | Card slides out in grade direction, next card fades in | 250ms | lightImpact |
| Mastery ring update | Arc animates to new value | 400ms | none |
| Pull to refresh | Circular indicator, sync surfaces only, never in the reader | - | lightImpact at threshold |
| Prayer logged | Checkbox fill plus row tint, 400ms hold, settles | 250ms | selectionClick |
| Download complete | Progress bar to check, ring collapses | 300ms | lightImpact |
| Error appears | Fade plus 4dp downward settle. No shake. | 200ms | lightImpact |
| Prayer time arrives | Nothing. Silent state change. | - | none |

### 7.1 Haptic rules

1. Tasbih gets the strongest haptic in the app because it is designed for eyes-closed, screen-off use. The user is counting by feel.
2. No haptic on any Athan or prayer-time event. A vibration during adhan is an interruption of worship.
3. No haptic on scroll, page turn or reading. Continuous haptics are exhausting and destroy battery.
4. Every haptic is disableable, one tap from the tasbih screen.

### 7.2 Anti-pattern list

Things that will be proposed and should be refused:

- Confetti on completing a juz - celebration theatre around worship
- Shake animation on validation error - punitive
- Bouncing badge on the streak counter - loss aversion by another name
- Pulsing upgrade glow - commerce inside a worship path, violates P4
- Animated progress rings that fill on every screen entry - attention-seeking on repeat exposure

---

## 8. Flutter icon libraries

### 8.1 Comparison

| Library | Package | Icons | Fit |
| --- | --- | --- | --- |
| Material Symbols | material_symbols_icons | 3,300+ | Recommended. Variable axes (FILL, wght, GRAD, opsz), three styles, first-party M3 alignment, RTL-aware glyphs. |
| Lucide | lucide_icons | 1,400+ | Beautiful, consistent 2px stroke. No fill variants, no variable axes, no RTL handling. |
| Phosphor | phosphor_flutter | 7,000+ x 6 weights | Huge and well built, but its weight system fights M3's FILL model. |
| Remix | remixicon | 2,800+ | Good outline/fill pairs. Inconsistent optical sizing. |
| Iconsax | iconsax | 1,000+ | Attractive but trend-coded. Will date. |
| Icons (SDK) | Flutter | ~2,000 | Legacy Material 2 shapes. Do not use. |

### 8.2 Recommendation

Material Symbols Rounded as the base set, plus a custom icon font for the nine religious glyphs.

- The FILL axis is our selected-state model. Continuous variable-font interpolation rather than swapping glyphs. Nothing else does this.
- Rounded, not Outlined or Sharp. Rounded terminals match our 2dp round-cap construction and the humanist warmth of Inter plus IBM Plex Sans Arabic.
- RTL correctness is built in. Directional glyphs mirror automatically; hand-rolled sets need a manual mirror list and something always gets missed.

### 8.3 Custom icons: font, not SVG widgets

```yaml
fonts:
  - family: QuranOneIcons
    fonts:
      - asset: assets/fonts/QuranOneIcons.ttf
```

```dart
abstract final class QIcons {
  static const mushaf = IconData(0xe900, fontFamily: 'QuranOneIcons');
  static const qibla  = IconData(0xe901, fontFamily: 'QuranOneIcons');
  static const kaaba  = IconData(0xe902, fontFamily: 'QuranOneIcons');
  static const athan  = IconData(0xe903, fontFamily: 'QuranOneIcons');
  static const tasbih = IconData(0xe904, fontFamily: 'QuranOneIcons');
  static const hifz   = IconData(0xe905, fontFamily: 'QuranOneIcons');
  static const juz    = IconData(0xe906, fontFamily: 'QuranOneIcons');
  static const sajdah = IconData(0xe907, fontFamily: 'QuranOneIcons');
  static const waqf   = IconData(0xe908, fontFamily: 'QuranOneIcons');
}
```

An icon font renders through the same text pipeline as Material Symbols, inherits IconTheme size and colour for free, costs about 6 KB, and cannot visually desynchronise from the base set. The font is generated by fantasticon from source SVGs in CI, so the source of truth is the drawings.

### 8.4 Wrapper widget

Nothing in the app uses Icon directly.

```dart
class QIcon extends StatelessWidget {
  const QIcon(this.icon, {
    super.key,
    this.size = QIconSize.md,
    this.filled = false,
    this.color,
    this.semanticLabel,
  });

  final IconData icon;
  final QIconSize size;
  final bool filled;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size.box,
      color: color ?? IconTheme.of(context).color,
      fill: filled ? 1.0 : 0.0,
      weight: size.stroke,
      grade: Theme.of(context).brightness == Brightness.dark ? -25 : 0,
      opticalSize: size.box,
      semanticLabel: semanticLabel,
    );
  }
}
```

Note grade: -25 in dark themes. Light strokes on dark backgrounds bloom optically and read heavier. Negative grade compensates.

---

## 9. Consistency rules

### 9.1 Enforced in CI

| Rule | Check |
| --- | --- |
| One icon library, no lucide/phosphor/Icons imports | Import lint |
| No bare Icon(...) outside design_system/ | Lint |
| No raw SVG asset used as an icon | Asset lint |
| Every icon in a tappable target has a semanticLabel | Widget test |
| Every icon in primary nav has a visible text label | Widget test |
| Illustrations only from assets/illustrations/, registered in a manifest | Asset lint |
| No PNG in the illustration directory | Asset lint |
| Every illustration has all three theme variants | Asset test |
| No .json or .riv animation assets in the bundle | Asset lint |

### 9.2 Human rules

1. An icon never appears alone in primary navigation. Icon plus label, always. Icon-only nav tests badly with every persona except Bilal, and catastrophically with Musa and Khadija.
2. One icon, one meaning, app-wide.
3. New icons need a documented use in two or more places, or the existing set gets reused.
4. Custom icons ship with their source SVG on the 24dp keyline template. No binary-only additions.
5. The illustration motif set is closed at six. New empty states recombine existing motifs; a seventh needs design lead sign-off.
6. Every empty, error and loading state is a real screen with real copy, reviewed against the copy doctrine lint in all 12 locales.

---

## 10. Onboarding illustrations

Four screens. Each a static SVG at 240 x 180dp, one motif, one tint.

| # | Screen | Motif | Headline | Purpose |
| --- | --- | --- | --- | --- |
| 1 | Welcome | Arch + light rays | The Qur'an, without noise | Sets the tone. No feature list. |
| 2 | Everything works offline | Arch with self-contained inner frame | Prayer times and the mushaf never need a connection | States the architectural promise as a benefit. |
| 3 | Choose your level | Three nested star polygons, one highlighted | We'll show you what's useful | Sets learning_level. The only screen that asks for input. |
| 4 | Private by default | Closed arch with an inner page | Your notes and progress stay yours | Encryption and no-ads stated plainly. |

Rules:

- Four screens, skippable from screen one. Amina will skip; that is correct behaviour, not a funnel leak.
- No account required. Anonymous-first.
- No permission requests during onboarding. Location is requested when the user first opens prayer times; notifications when they first enable an Athan.
- No fake data in mockups.
- Screen 3 options are New to the Qur'an / I read regularly / I'm memorising. Plain language, changeable later.

---

## 11. Asset inventory, v1

| Category | Count | Format | Est. size |
| --- | --- | --- | --- |
| Material Symbols Rounded (variable) | 1 font | ttf | ~180 KB |
| Custom religious icons | 9 | Icon font | ~6 KB |
| Empty state illustrations | 9 | SVG x 3 themes | ~72 KB |
| Error illustrations | 4 | SVG x 3 themes | ~32 KB |
| Onboarding illustrations | 4 | SVG x 3 themes | ~40 KB |
| Total | | | ~330 KB |

The entire visual language costs a third of a megabyte against an 80 MB budget. That is what choosing static vector over Lottie buys.

---

## 12. Three positions to defend in review

1. The no-figurative rule will be challenged as limiting, and it is the strongest decision here. A friendly character would warm up onboarding, and it would also impose a theological ruling users did not authorise. Geometry and architecture are universal across every madhhab and region in our persona set.
2. Refusing Lottie will be unpopular. The disqualifier is not taste: a baked composition cannot mirror for RTL, cannot theme across three palettes, and cannot honour reduced motion. In an Arabic-first, tri-theme, accessibility-gated product it is structurally incompatible.
3. "Prayer time arrives, no animation" will read as an oversight. It is not. Every competitor treats the adhan as a moment to celebrate with motion. The moment belongs to the user, and the most respectful thing the interface can do at Maghrib is change quietly.
