# Quran One - Accessibility Guidelines

Codename: Mizan. Companion to DESIGN_SYSTEM.md, COLOR_SYSTEM.md, TYPOGRAPHY_SYSTEM.md, COMPONENT_LIBRARY.md, NAVIGATION.md and MOTION_SYSTEM.md.

Target: WCAG 2.2 Level AA, plus a small set of self-imposed AAA obligations on Quranic text.

---

## 0. The framing

Accessibility in most products is a compliance exercise bolted on before launch. Here it is a product requirement with a religious dimension: **a blind hafiz, an elderly imam with presbyopia, and a user with a tremor all have the same claim on the Quran as anyone else.** An inaccessible Quran app is not a slightly worse app; it withholds scripture.

Three consequences:

1. **Accessibility is a release gate, not a backlog category.** The checks in section 14 block merge and block release.
2. **We exceed AA where scripture is involved.** Quranic text holds a 12:1 contrast floor - well beyond the 4.5:1 AA requirement and beyond the 7:1 AAA requirement.
3. **We test with users, not only with tools.** Automated checks catch roughly a third of real barriers. The M4 closed beta includes a minimum of 12 participants using assistive technology daily.

---

## 1. WCAG 2.2 AA conformance

### 1.1 Perceivable

| SC | Level | How we satisfy it |
| --- | --- | --- |
| 1.1.1 Non-text Content | A | Every QIcon requires semanticLabel. Decorative illustrations are ExcludeSemantics. Reciter artwork has the reciter name as its label. |
| 1.2.x Time-based Media | A/AA | Recitation audio has synchronised Arabic text as its equivalent. Video tutorials ship with captions and transcripts. |
| 1.3.1 Info and Relationships | A | Headings expose header: true. Lists expose their structure. Form fields are programmatically associated with labels. |
| 1.3.2 Meaningful Sequence | A | Traversal order is verified per screen with a semantics-order test. |
| 1.3.4 Orientation | AA | Every screen works in portrait and landscape. Nothing is locked. |
| 1.3.5 Identify Input Purpose | AA | autofillHints on email, password, name. |
| 1.4.1 Use of Color | A | Colour is never the sole carrier of meaning. See section 6. |
| 1.4.3 Contrast (Minimum) | AA | Contrast floors in section 9 exceed the requirement everywhere. |
| 1.4.4 Resize Text | AA | Supported to 200 percent. Text scale is never clamped. |
| 1.4.5 Images of Text | AA | No image-of-text anywhere. The mushaf is live text in an OpenType font, not page scans - this is a founding decision, see section 4.4. |
| 1.4.10 Reflow | AA | No two-dimensional scrolling at 320 CSS px equivalent. |
| 1.4.11 Non-text Contrast | AA | Icons, focus rings, and sole-affordance borders hold 3.5:1 against 3:1 required. |
| 1.4.12 Text Spacing | AA | Line height, paragraph, letter and word spacing overrides do not clip content. |
| 1.4.13 Content on Hover or Focus | AA | Tooltips are dismissible, hoverable, persistent. |

### 1.2 Operable

| SC | Level | How we satisfy it |
| --- | --- | --- |
| 2.1.1 Keyboard | A | Every function reachable from a keyboard. See section 7. |
| 2.1.2 No Keyboard Trap | A | Focus traps only in modals, always escapable with Esc. |
| 2.1.4 Character Key Shortcuts | A | All single-key shortcuts are remappable and suppressed while a text field has focus. |
| 2.2.1 Timing Adjustable | A | Nothing in the app times out. Review sessions have no timer. |
| 2.2.2 Pause, Stop, Hide | A | No auto-playing motion over 5 seconds; no infinite loops outside indeterminate progress. |
| 2.3.1 Three Flashes | A | Nothing flashes at all. |
| 2.4.3 Focus Order | A | Logical and direction-aware. |
| 2.4.4 Link Purpose | A | No "read more". Every action names its target. |
| 2.4.6 Headings and Labels | AA | Descriptive, unique per screen. |
| 2.4.7 Focus Visible | AA | 2dp ring, 3.5:1, never suppressed. |
| 2.4.11 Focus Not Obscured | AA (2.2) | Sticky app bars and sheets scroll focused elements clear. |
| 2.5.1 Pointer Gestures | A | Every multi-point or path gesture has a single-pointer alternative. See section 8.3. |
| 2.5.2 Pointer Cancellation | A | Actions fire on up-event; drag away to cancel. |
| 2.5.3 Label in Name | A | The accessible name always contains the visible label text. |
| 2.5.4 Motion Actuation | A | Qibla works without device motion via a manual compass entry fallback. |
| 2.5.7 Dragging Movements | AA (2.2) | Reorder, sliders and the audio scrubber all have tap or button alternatives. |
| 2.5.8 Target Size (Minimum) | AA (2.2) | 48x48dp minimum, above the 24x24 requirement. See section 8. |

### 1.3 Understandable and Robust

| SC | Level | How we satisfy it |
| --- | --- | --- |
| 3.1.1 Language of Page | A | Locale set on MaterialApp. |
| 3.1.2 Language of Parts | AA | Arabic spans inside non-Arabic UI carry an explicit locale so screen readers switch voice. Critical - see section 3.5. |
| 3.2.1 On Focus | A | Focus never changes context. |
| 3.2.2 On Input | A | No control auto-submits on change without warning. |
| 3.2.6 Consistent Help | A (2.2) | Help is in the same place on every screen. |
| 3.3.1 Error Identification | A | Errors in text, not colour, adjacent to the field. |
| 3.3.2 Labels or Instructions | A | Persistent labels, not placeholder-only fields. |
| 3.3.7 Redundant Entry | A (2.2) | Nothing is asked twice in a flow. |
| 3.3.8 Accessible Authentication | AA (2.2) | No cognitive-function test. Passwordless and biometric supported; paste is never blocked. |
| 4.1.2 Name, Role, Value | A | Every custom widget declares all three. |
| 4.1.3 Status Messages | AA | SemanticsService.announce for async results. |

### 1.4 Where we exceed AA deliberately

| Area | Requirement | Ours |
| --- | --- | --- |
| Quranic text contrast | 4.5:1 | **12:1** |
| Translation text contrast | 4.5:1 | **8:1** |
| Body text contrast | 4.5:1 | **5.5:1** |
| Touch targets | 24x24 | **48x48** |
| Non-text contrast | 3:1 | **3.5:1** |
| Text resize | 200 percent | **200 percent, never clamped, layout verified** |

---

## 2. RTL and bidirectional text

### 2.1 Why this is an accessibility issue, not a localisation issue

For an Arabic-first user, a broken RTL layout is not cosmetic. A back chevron pointing the wrong way, a progress bar filling from the wrong edge, or a slider whose minimum is on the wrong side are all comprehension failures. Our largest single user group reads right to left.

### 2.2 Banned and required APIs

| Banned | Required |
| --- | --- |
| EdgeInsets.only(left:/right:) | EdgeInsetsDirectional.only(start:/end:) |
| Alignment.centerLeft / centerRight | AlignmentDirectional.centerStart / centerEnd |
| Positioned(left:/right:) | PositionedDirectional(start:/end:) |
| TextAlign.left / right | TextAlign.start / end |
| BorderRadius.only(topLeft:) | BorderRadiusDirectional.only(topStart:) |
| Icons.arrow_back | Icons.arrow_back with automatic mirroring, or a directional resolver |
| Hard-coded Offset(1.0, 0) in transitions | Direction-resolved offsets, or a non-directional transition |

All seven are enforced by custom lints that block merge.

### 2.3 Bidirectional text isolation

Mixed-direction runs are the most common source of garbled text in Islamic apps: an Arabic surah name inside an English sentence, or a Latin reciter name inside an Arabic one. Without isolation the numbers and punctuation migrate to the wrong end.

```dart
// First Strong Isolate / Pop Directional Isolate.
String isolate(String s) => '\u2068$s\u2069';

// Example: "Surah Al-Baqarah, ayah 255" in an Arabic UI
Text(l10n.ayahReference(isolate(surahName), isolate('$ayahNumber')));
```

Every interpolated string in the ARB files that can carry the opposite direction is isolated. A lint flags interpolations that are not.

### 2.4 What mirrors and what does not

| Mirrors | Does not mirror |
| --- | --- |
| Layout, navigation rail, tabs, sheets | **Mushaf page turn - always RTL in every locale** |
| Back and forward chevrons | The Kaaba icon |
| Progress fill direction | Clock faces and the Qibla compass rose |
| Sliders and scrubbers | Numerals within a number |
| Skeleton shimmer sweep | Media playback controls (play always points forward-in-time, per platform convention) |

### 2.5 Verification

Every component carries 24 goldens: 3 themes x 2 directions x 4 text scales. A component cannot merge without its RTL goldens. This is the only mechanism that reliably catches mirroring regressions.

---

## 3. Screen readers

### 3.1 The semantic contract

Every interactive widget declares name, role, value, and state. Every custom-painted widget declares all four manually, because CustomPaint produces no semantics by default.

```dart
Semantics(
  label: l10n.ayahLabel(surahName, ayahNumber),
  value: isBookmarked ? l10n.bookmarked : null,
  button: true,
  onTapHint: l10n.opensVerseActions,
  child: ExcludeSemantics(child: _visualAyahCard()),
)
```

### 3.2 The ayah reading problem

This is the hardest screen-reader problem in the product and it has no off-the-shelf solution.

A naive implementation gives each ayah a Semantics node whose label is the full Arabic text. TalkBack and VoiceOver then read the ayah in their own synthetic voice, at their own rate, with their own pronunciation of Quranic Arabic - which is frequently wrong, because general-purpose TTS does not handle tajweed marks, waqf signs, or the U+06DD end-of-ayah glyph.

**Our position: the screen reader announces the reference and offers recitation; it does not attempt to recite.**

| Element | Announced |
| --- | --- |
| Ayah node label | "Al-Baqarah, ayah 255" plus the first clause of the selected translation |
| Custom action 1 | "Play recitation" - authoritative audio from a qari, not TTS |
| Custom action 2 | "Read full translation" |
| Custom action 3 | "Bookmark" |
| Custom action 4 | "Open verse actions" |
| Waqf and sajdah marks | Announced as named marks, never read as characters |

A user who wants the Arabic read aloud gets a human reciter. That is both more accurate and more appropriate.

An override exists in Settings - "Announce Arabic text" - for users who prefer TTS, defaulting off, with a note explaining why.

### 3.3 Reading order

```dart
Semantics(
  sortKey: const OrdinalSortKey(1),
  child: _surahHeader(),
),
Semantics(
  sortKey: const OrdinalSortKey(2),
  child: _basmalah(),
),
// Ayahs follow in document order.
```

Explicit sort keys are used wherever visual order and widget order can diverge - notably the reader header, the audio bar, and any Stack.

### 3.4 Announcements

```dart
SemanticsService.announce(
  l10n.bookmarkAdded(surahName, ayahNumber),
  Directionality.of(context),
  assertiveness: Assertiveness.polite,
);
```

Polite for confirmations. Assertive is reserved for exactly two cases: a failed payment and a sync conflict requiring a decision. Nothing about worship is ever announced assertively.

### 3.5 Language switching mid-content

This is the single most impactful and most-skipped screen-reader behaviour in a bilingual religious app. An Arabic string inside an English UI must be tagged, or the screen reader reads it with an English voice and it is incomprehensible.

```dart
Semantics(
  attributedLabel: AttributedString(
    arabicText,
    attributes: [
      LocaleStringAttribute(
        range: TextRange(start: 0, end: arabicText.length),
        locale: const Locale('ar'),
      ),
    ],
  ),
  child: child,
)
```

Applied to: surah names, ayah text where announcement is enabled, dua text, azkar text, hadith Arabic, and reciter names in Arabic.

### 3.6 What is hidden from screen readers

| Hidden | Reason |
| --- | --- |
| Decorative illustrations and ornaments | No informational content |
| Skeletons | Announce a single "Loading" instead of 20 empty nodes |
| Duplicate visual text inside a labelled Semantics wrapper | Prevents double-reading |
| Page-frame ornamentation in the mushaf | Decoration |
| The mini player when the full player is open | Prevents duplicate controls |

---

## 4. Large text

### 4.1 The rule

**Text scale is never clamped. Not on any screen, not for any element.**

Clamping textScaleFactor is the most common accessibility defect in Flutter apps and it is invariably introduced to protect a layout. The layout is the thing that should change.

```dart
// BANNED anywhere in the codebase - enforced by lint.
MediaQuery(
  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
  child: child,
)
```

### 4.2 Layout consequences

| Pattern | Rule |
| --- | --- |
| Fixed-height containers around text | Banned. Use minHeight constraints. |
| Single-line labels | maxLines omitted or set generously; wrapping preferred to ellipsis |
| Rows of label + value | Become Columns above 150 percent scale via a LayoutBuilder |
| Bottom nav labels | Wrap to two lines; bar grows |
| Buttons | Grow vertically; text never truncates |
| Dialogs | Become scrollable above 175 percent |
| Tables | Become stacked cards above 150 percent |

```dart
final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
return scale > 1.5
    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: children)
    : Row(children: children);
```

### 4.3 Arabic and large text

Arabic requires more vertical space than Latin at the same point size because of diacritics above and below the baseline. Our line-height floors already account for this: Arabic 1.70, Arabic long-form 1.80, Quranic 2.00, with kArabicScale = 1.10 applied to Arabic type. At 200 percent system scale these multiply, and every Arabic surface is golden-tested at that combination.

### 4.4 Independent reading sliders

The reader provides two size controls independent of the system setting and of each other:

| Slider | Range | Default |
| --- | --- | --- |
| Arabic size | 18-48sp | 26sp |
| Translation size | 14-32sp | 17sp |

They are independent because the needs diverge: a hafiz may want large Arabic and no translation, while a beginner may want modest Arabic and large translation. A single coupled slider serves neither.

**This is also why the mushaf is live text rather than page images.** Page scans are the cheap route to layout fidelity and every one of them is an image of text that cannot be resized, cannot be selected, cannot be searched, and cannot be read by a screen reader. Rendering 604 pages from an OpenType font is materially harder - AR-1 in the risk register is entirely about page-break drift - and it is the correct decision.

---

## 5. Contrast

### 5.1 Floors

| Content | Ratio | Basis |
| --- | --- | --- |
| Quranic text | 12:1 | Self-imposed |
| Translation text | 8:1 | Self-imposed |
| Body text | 5.5:1 | Above AA |
| Large text (24sp+, or 19sp bold) | 4.5:1 | Above AA |
| Icons, focus rings, sole-affordance borders | 3.5:1 | Above AA |
| Disabled controls | 3:1 | Exempt, held anyway |
| Decorative dividers | None | Exempt |

### 5.2 Verified values

| Theme | Element | Value | Ratio |
| --- | --- | --- | --- |
| Light | Primary text on background | #16181C on #FBF8F3 | 16.8:1 |
| Light | Secondary text | #5A5D63 on #FBF8F3 | 6.2:1 |
| Light | Default icon | #3A3D42 | 10.3:1 |
| Light | White on primary | #FFFFFF on #1F4A3C | 10.0:1 |
| Dark | Primary text | #E4E1DC on #14161A | 13.9:1 |
| Dark | Secondary text | #A8A5A0 | 7.4:1 |
| AMOLED | Primary text | #D9D6D1 on #000000 | 14.5:1 |
| AMOLED | Secondary text | #A3A09B | 7.8:1 |

**AMOLED ink is never pure #FFFFFF.** Pure white on pure black produces halation that makes vocalised Arabic diacritics bleed into the glyph body. #D9D6D1 at 14.5:1 is both more comfortable and still far above any requirement.

### 5.3 Enforcement

A golden-analysis step samples rendered text and background pixels across all three themes and fails the build on any violation. Contrast is computed against actual rendered output, not against the token table, because a translucent overlay can silently break a pairing that looks fine on paper.

---

## 6. Colour blindness

Roughly 1 in 12 men and 1 in 200 women have a colour vision deficiency. In our audience that is a large absolute number.

### 6.1 The rule

**Colour is never the sole carrier of meaning.** Every colour-coded state also carries an icon, a label, a shape, or a position.

| Meaning | Colour | Redundant carrier |
| --- | --- | --- |
| Selected chip or segment | secondaryContainer | Check icon |
| Switch on | Primary track | Check glyph in the thumb |
| Hadith grading (sahih, hasan, daif) | Tone | **Text label always. Grading is never a coloured dot.** |
| Hifz mastery level | Ring fill | Numeric percentage plus level name |
| Sync state | Tone | Icon plus status text |
| Prayer status (passed, current, next) | Tone | Icon plus label plus position in the list |
| Error field | error | Icon plus message text |
| Premium feature | - | Text label, never a coloured badge |

### 6.2 The two known collisions

**Success green versus primary green.** Our primary is Mihrab #1F4A3C and success is #2D6A4F. Under deuteranopia these are close. Mitigated by never placing them adjacent and by always pairing success with a check icon and a label.

**Tajweed colouring.** This is the genuinely hard one. Tajweed rules are conventionally colour-coded, the colour set is traditional, and users expect it. Our mitigations:

1. Tajweed colouring is **off by default**.
2. When on, a **CVD-safe palette** is available as an alternative, tuned for deuteranopia and protanopia.
3. A **letter-shape underline mode** encodes rules by underline style - solid, dashed, dotted, double - instead of or in addition to colour.
4. Long-pressing any coloured letter names the rule in text.

### 6.3 Verification

Every golden is additionally rendered through deuteranopia, protanopia and tritanopia simulation filters. A reviewer must confirm each simulated image is still interpretable. This is a human step; there is no automated substitute for judging comprehension.

---

## 7. Keyboard navigation

Required for Flutter web, tablet users with keyboards, switch-access users, and anyone with a motor impairment who cannot use touch reliably.

### 7.1 Focus

| Property | Value |
| --- | --- |
| Ring | 2dp, primary, 3.5:1 minimum, 2dp offset |
| Motion | 150ms fade |
| Order | Direction-aware: start to end, top to bottom |
| Skip link | "Skip to content" as the first focusable element on web |
| Traps | Modals only; Esc always escapes |
| Restoration | Closing a modal returns focus to the element that opened it |

The focus ring is never suppressed. `FocusManager.instance.highlightStrategy` is left at its default so the ring appears for keyboard use and not for touch.

### 7.2 Global shortcuts

| Key | Action |
| --- | --- |
| Ctrl/Cmd + K | Open search |
| Ctrl/Cmd + , | Settings |
| 1-4 | Switch bottom-nav destination |
| Esc | Close sheet, dialog, or search |
| ? | Shortcut reference |

### 7.3 Reader shortcuts

| Key | Action |
| --- | --- |
| Arrow start / end | Previous / next page - **resolved against text direction** |
| Arrow up / down | Previous / next ayah |
| Space | Play or pause recitation |
| B | Bookmark current ayah |
| T | Toggle translation |
| G | Go to surah, ayah, page or juz |
| +/- | Increase or decrease Arabic size |

All shortcuts are remappable and all are suppressed while a text field holds focus, satisfying SC 2.1.4.

```dart
Shortcuts(
  shortcuts: <ShortcutActivator, Intent>{
    const SingleActivator(LogicalKeyboardKey.arrowRight):
        DirectionalPageIntent(fromArrow: AxisDirection.right),
  },
  child: Actions(
    actions: <Type, Action<Intent>>{
      DirectionalPageIntent: CallbackAction<DirectionalPageIntent>(
        onInvoke: (intent) {
          // Resolve the arrow against text direction, then apply the
          // mushaf's always-RTL page order.
          final ltr = Directionality.of(context) == TextDirection.ltr;
          final forward = intent.fromArrow == AxisDirection.right ? !ltr : ltr;
          return _turnPage(forward: forward);
        },
      ),
    },
    child: child,
  ),
)
```

---

## 8. Touch targets and motor accessibility

### 8.1 Minimum size

**48x48dp, everywhere, without exception.** WCAG 2.2 SC 2.5.8 requires 24x24; the platform guidelines say 44-48; we take the larger figure and apply it universally.

Visual size and target size are decoupled. A 20dp icon sits in a 48dp target.

```dart
class QTapTarget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: Center(child: child),
      );
}
```

A widget test walks every screen and fails on any hit-test region below 48dp in either axis.

### 8.2 Spacing

Minimum 8dp between adjacent targets. Destructive actions get 16dp from anything else, and never sit adjacent to a cancel.

### 8.3 Gesture alternatives

Every gesture has a discoverable non-gesture equivalent, per SC 2.5.1 and 2.5.7.

| Gesture | Alternative |
| --- | --- |
| Swipe to turn page | Tap zones at both page edges, plus keyboard, plus a Go To control |
| Long-press ayah | Tap ayah number opens the same sheet |
| Swipe to delete | Overflow menu on every dismissible row |
| Drag to reorder | Move up / Move down in the overflow menu, and screen-reader custom actions |
| Pinch to zoom text | Size sliders in the display sheet |
| Drag the audio scrubber | Skip back / forward buttons in 5-second steps |
| Rotate device for Qibla | Manual heading entry |
| Pull to refresh | Refresh action in the app bar |

### 8.4 Tremor and precision

- No double-tap requirement anywhere.
- No timed interaction anywhere.
- Actions fire on pointer-up, and dragging away before release cancels them (SC 2.5.2).
- The tasbih counter has a large 120dp primary target and cannot be decremented by accident - undo is a separate explicit control.

---

## 9. VoiceOver (iOS)

| Feature | Support |
| --- | --- |
| Rotor - headings | header: true on every section heading |
| Rotor - custom actions | Bookmark, play, translate, share, add to Hifz on every ayah |
| Magic Tap (two-finger double-tap) | Play / pause recitation |
| Escape (two-finger scrub) | Close sheet or dialog |
| Large Content Viewer | Supported on all app bar and nav items |
| Voice Control | Every control has a spoken-name label matching its visible label |
| Braille display | Full text output; ayah references in the status line |
| Announcements | UIAccessibility.post equivalents via SemanticsService |

```dart
Semantics(
  customSemanticsActions: <CustomSemanticsAction, VoidCallback>{
    CustomSemanticsAction(label: l10n.playRecitation): _play,
    CustomSemanticsAction(label: l10n.bookmark): _bookmark,
    CustomSemanticsAction(label: l10n.readTranslation): _translate,
    CustomSemanticsAction(label: l10n.addToHifz): _addToHifz,
  },
  child: child,
)
```

**Custom actions are what make this app usable non-visually.** Without them, reaching "bookmark" on ayah 255 means swiping past every intervening control. With them it is two gestures.

---

## 10. TalkBack (Android)

| Feature | Support |
| --- | --- |
| Reading controls - headings | header: true |
| Local context menu actions | Same four custom actions as VoiceOver |
| Explore by touch | Every visual element has a semantics node or is explicitly excluded |
| Switch Access | Full traversal; no element reachable only by gesture |
| Select to Speak | Live text everywhere means it works, including the mushaf |
| Braille keyboard | Standard text field support |
| Announcements | SemanticsService.announce with polite assertiveness |

### 10.1 Android-specific hazards we handle

| Hazard | Handling |
| --- | --- |
| TalkBack reads a Semantics label and its child Text twice | ExcludeSemantics on the visual child |
| Custom-painted widgets are invisible to TalkBack | Every CustomPaint has an explicit Semantics wrapper |
| Display size (density) setting, separate from font size | Layouts tested at the largest display size and largest font together |
| Notification actions | Athan notification actions carry contentDescription |
| OEM accessibility service variance | Verified on Samsung One UI and Xiaomi HyperOS on the device farm |

---

## 11. Reduced motion

Reduced motion is not the absence of motion. Vestibular triggers are large-displacement and parallax motion, not opacity change. See MOTION_SYSTEM.md section 12 for the full mapping.

| Category | Normal | Reduced |
| --- | --- | --- |
| Page transitions | Fade-through / shared-axis | Cross-fade 150ms |
| Hero flights | Full flight | Disabled |
| Sheets and snackbars | Slide | Fade in place |
| Dialogs | Fade plus scale | Fade only |
| Shimmer | Sweeping | Static fill |
| Page turn | Slide | Cross-fade |
| Indeterminate spinners | Rotate | **Retained** - conveys ongoing work |
| Determinate progress | Tween | **Retained** - conveys real information |
| Colour and opacity changes | 150-250ms | Retained |

Two switches, either of which wins: the OS setting (MediaQuery.disableAnimationsOf) and our own in-app setting. We ship our own because the OS setting is global, and a user may reasonably want a lively phone and a still Quran app.

---

## 12. Flutter accessibility best practices

### 12.1 Do and do not

| Do | Do not |
| --- | --- |
| Wrap custom widgets in Semantics with label, role, value | Assume CustomPaint is announced |
| ExcludeSemantics on visual children of a labelled wrapper | Let the same text be read twice |
| MergeSemantics for a label plus value pair | Leave two nodes the user must swipe through |
| Use MediaQuery.textScalerOf | Use the deprecated textScaleFactor |
| Provide customSemanticsActions | Require spatial navigation to reach an action |
| Use LocaleStringAttribute on opposite-language runs | Let an English voice read Arabic |
| Use EdgeInsetsDirectional everywhere | Use EdgeInsets.only(left:) |
| Add a semantics-order test per screen | Trust widget order to equal reading order |
| Test with a real screen reader | Rely on the semantics debugger alone |
| Let layouts reflow | Clamp textScaler |

### 12.2 The wrapper pattern

```dart
// One labelled node instead of five, with actions attached.
Semantics(
  label: l10n.prayerRowLabel(name, time),
  value: isNext ? l10n.nextPrayer : null,
  button: true,
  customSemanticsActions: {
    CustomSemanticsAction(label: l10n.logPrayer): onLog,
    CustomSemanticsAction(label: l10n.athanSettings): onSettings,
  },
  child: ExcludeSemantics(
    child: QPrayerRowVisual(name: name, time: time, isNext: isNext),
  ),
)
```

### 12.3 Testing

```dart
testWidgets('QPrayerRow exposes a single labelled node with actions',
    (tester) async {
  final handle = tester.ensureSemantics();
  await tester.pumpWidget(_wrap(const QPrayerRow(...)));

  expect(
    tester.getSemantics(find.byType(QPrayerRow)),
    matchesSemantics(
      label: 'Dhuhr, 1:24 PM',
      isButton: true,
      hasTapAction: true,
      customActions: const ['Log prayer', 'Athan settings'],
    ),
  );

  await expectLater(tester, meetsGuideline(textContrastGuideline));
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

  handle.dispose();
});
```

All four Flutter accessibility guidelines run on every widget test. They are cheap and they catch the majority of regressions.

### 12.4 Semantics debugging

```dart
// Debug builds only, behind a developer setting.
MaterialApp(showSemanticsDebugger: kDebugMode && _semanticsDebug, ...)
```

---

## 13. Testing programme

### 13.1 Automated

| Layer | Runs | Catches |
| --- | --- | --- |
| Flutter accessibility guidelines | Every widget test | Contrast, tap targets, missing labels |
| Semantics-order tests | Per screen | Traversal defects |
| Golden suite, 3 themes x 2 directions x 4 scales | Every PR | RTL mirroring, large-text overflow, contrast |
| CVD simulation goldens | Every PR | Colour-only meaning |
| Directional-API lints | Every PR | Banned LTR-only APIs |
| Text-scale clamp lint | Every PR | textScaler suppression |
| 48dp target sweep | Nightly | Undersized targets |

### 13.2 Manual

| Cadence | Activity |
| --- | --- |
| Every sprint | One screen fully traversed with TalkBack and one with VoiceOver |
| Every milestone | Full keyboard-only pass on web |
| Every milestone | Full pass at 200 percent text scale, both directions |
| M4 closed beta | Minimum 12 participants who use assistive technology daily |
| Pre-GA | Third-party WCAG 2.2 AA audit |

### 13.3 The critical journeys

These five must be completable end to end with a screen reader, with keyboard only, and at 200 percent text scale. Any regression is a release blocker.

1. Open the app and read ayah 255 of Al-Baqarah with translation.
2. Find the next prayer time and enable its athan.
3. Bookmark an ayah and find it again from Saved.
4. Complete a Hifz review session.
5. Change the theme, Arabic size and translation.

---

## 14. Release gates

| Gate | Blocks |
| --- | --- |
| Zero WCAG 2.2 AA violations in the automated suite | Merge |
| All 24 goldens present and passing per component | Merge |
| No banned directional API | Merge |
| No textScaler clamping | Merge |
| All contrast floors met in all three themes | Merge |
| Every interactive element has a non-null semantic label | Merge |
| Every gesture has a documented alternative | Release |
| Five critical journeys pass with TalkBack and VoiceOver | Release |
| Third-party audit clean | GA |

---

## 15. Four positions worth arguing about

**1. Refusing to let the screen reader recite Arabic will be read as withholding a feature.** It is the opposite. General-purpose TTS mispronounces Quranic Arabic, ignores waqf marks, and reads the end-of-ayah glyph as a character. Offering a human reciter as the custom action is more accurate and more respectful. The override exists for users who disagree, and it defaults off.

**2. Live mushaf text instead of page images costs roughly 14 development weeks and carries AR-1, our highest-severity content risk.** Page scans would eliminate the page-break problem entirely. They would also make the mushaf unresizable, unselectable, unsearchable and completely invisible to screen readers. This is the single most consequential accessibility decision in the product and it is not reversible later.

**3. Universal 48dp targets will be called wasteful on dense screens like the surah index.** Twenty-four dp is what WCAG 2.2 requires. Forty-eight is what a user with a tremor actually needs, and the surah index is a list somebody navigates 20 times a day.

**4. Tajweed colouring is off by default, which will be contested by advanced users.** Tajweed colour is the most accessibility-hostile convention in Islamic apps: purely colour-encoded, traditionally palettised, and not adjustable in any competitor. Off by default with a CVD-safe palette and an underline mode is the responsible starting position; a first-run prompt for users who want it is the compromise worth discussing.
