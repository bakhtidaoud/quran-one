# Quran One - Component Library

Codename: Mizan. Companion to DESIGN_SYSTEM.md, COLOR_SYSTEM.md, TYPOGRAPHY_SYSTEM.md and VISUAL_LANGUAGE.md.

---

## 0. Contract

Every component in this library obeys eight rules. They are enforced in CI, not by review discipline.

1. Q-prefixed, no Material widget is used directly in feature code.
2. Stateless where possible. State lives in Riverpod providers, never inside a component.
3. No colour, size, radius, duration or text style is hard-coded. Everything resolves from Theme or a ThemeExtension.
4. Directional insets only. EdgeInsetsDirectional, AlignmentDirectional, PositionedDirectional, TextAlign.start.
5. Minimum 48 x 48dp touch target, regardless of visual size.
6. Every interactive component accepts a semanticLabel or derives one, and exposes onPressed: null as the sole disabled mechanism.
7. No component sets a fixed height around text. Everything reflows to 200 percent text scale.
8. 24 goldens per component: 3 themes x 2 directions x 4 text scales.

### 0.1 The disabled-state rule

There is no `enabled` parameter anywhere in this library. A null callback is the only way to disable a control. Two sources of truth for one state produce components that are visually enabled and functionally dead, which is the most common bug class in design systems.

### 0.2 Shared enums

```dart
enum QSize { small, medium, large }
enum QIconSize { xs, sm, md, lg, xl }

enum QButtonVariant { primary, secondary, tonal, outlined, text, destructive }
enum QFeedbackTone { neutral, success, warning, error, info }
```

---

## 1. Buttons

### 1.1 API

```dart
class QButton extends StatelessWidget {
  const QButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = QButtonVariant.primary,
    this.size = QSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = false,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;      // null == disabled, the only mechanism
  final QButtonVariant variant;
  final QSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool fullWidth;
  final String? semanticLabel;
}

class QIconButton extends StatelessWidget {
  const QIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,     // required, not optional
    this.variant = QButtonVariant.text,
    this.size = QIconSize.md,
    this.filled = false,
    this.badgeCount,
  });
}
```

### 1.2 Variants

| Variant | Fill | Label | Border | Use |
| --- | --- | --- | --- | --- |
| primary | primary | onPrimary | none | The one main action on a screen |
| secondary | secondaryContainer | onSecondaryContainer | none | Supporting action |
| tonal | primaryContainer | onPrimaryContainer | none | Medium emphasis in dense surfaces |
| outlined | transparent | primary | 1dp outline | Alternative to a filled action |
| text | transparent | primary | none | Lowest emphasis, inline |
| destructive | error | onError | none | Delete account, clear data, remove download |

### 1.3 Sizes

| Size | Height | Horizontal padding | Text style | Radius |
| --- | --- | --- | --- | --- |
| small | 36dp (48dp target) | 16dp | button.small | q.shape.sm 8 |
| medium | 44dp (48dp target) | 20dp | button.medium | q.shape.md 12 |
| large | 52dp | 24dp | button.large | q.shape.md 12 |

The small button is 36dp tall visually but wrapped in a 48dp tap target. Visual density and touch accessibility are separate concerns and must not be conflated.

### 1.4 Loading state

```dart
QButton(
  label: 'Download juz',
  isLoading: state.isDownloading,
  onPressed: state.isDownloading ? null : ref.read(...).download,
)
```

The button retains its resting width while loading. A button that shrinks to a spinner causes surrounding layout to jump, and the user loses the target they were about to tap again. The label fades to 0 and a 16dp indeterminate indicator cross-fades in over the same 150ms.

### 1.5 Best practices

- One primary button per screen. Two primaries means neither is primary.
- Labels are verbs, sentence case, one or two words. "Download", not "Click here to download".
- Destructive actions never sit adjacent to their cancel. Minimum 16dp gap, destructive at the end.
- No button in the reading canvas. The reader's chrome auto-hides; buttons live in sheets.
- Never disable a submit button to communicate validation failure. Show the error, keep the button live, explain on tap. A disabled button with no explanation is a dead end.
- Arabic labels wrap rather than ellipsise. Ellipsised Arabic loses the joining context and becomes unreadable.

---

## 2. Cards

### 2.1 API

```dart
class QCard extends StatelessWidget {
  const QCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsetsDirectional.all(16),
    this.elevation = QElevation.level1,
    this.tone = QFeedbackTone.neutral,
    this.semanticLabel,
  });
}

class QAyahCard extends StatelessWidget {
  const QAyahCard({
    super.key,
    required this.ayah,
    required this.displayMode,        // arabicOnly | withTranslation | withTafsir
    this.isPlaying = false,
    this.isBookmarked = false,
    this.highlight,                   // QHighlightColor?
    this.onTap,
    this.onLongPress,
    this.onBookmarkToggle,
    this.onPlay,
  });
}
```

### 2.2 Elevation by theme

| Theme | Mechanism |
| --- | --- |
| Light | Surface #FFFFFF on background #FBF8F3, plus a shadow at blur = dp x 2, opacity 0.08 max |
| Dark | Tonal overlay, card #212429 on background #14161A. No shadow. |
| AMOLED | 1dp hairline border #161616. No tonal shift, no shadow. |

This is handled by the theme, not by the component. QCard never branches on brightness.

### 2.3 Best practices

- Cards do not nest. A card inside a card produces two competing elevation stories and unreadable radius nesting.
- If a card is tappable, the whole card is the target. A card with a small button inside and a tappable body has two overlapping targets and fails screen-reader traversal.
- Nested radius: inner = outer minus padding. A 12dp card with 16dp padding takes an 8dp inner radius, never 12dp.
- QAyahCard never animates its text. During playback the background cross-fades; the ayah stays fixed. Text that scales or shifts while a user is following recitation is disorienting.

---

## 3. Dialogs

### 3.1 API

```dart
class QDialog extends StatelessWidget {
  const QDialog({
    super.key,
    required this.title,
    this.body,
    this.icon,
    this.tone = QFeedbackTone.neutral,
    this.primaryAction,               // QDialogAction?
    this.secondaryAction,
    this.isDismissible = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required QDialog dialog,
  });
}

class QDialogAction {
  const QDialogAction({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
  });
}
```

### 3.2 Specification

| Property | Value |
| --- | --- |
| Max width | 400dp, centred |
| Radius | q.shape.xl 28 |
| Padding | 24dp all sides |
| Title | headline.small |
| Body | body.medium at onSurfaceVariant |
| Actions | Aligned to end, 8dp gap, secondary first |
| Scrim | scrim at 32 percent |
| Enter | Fade plus scale 0.92 to 1.0 over q.motion.medium |

### 3.3 Best practices

- Maximum two actions. Three means the question is wrong; use a bottom sheet.
- The title is the question, not a label. "Delete this note?" not "Confirm".
- Destructive confirmation requires the action verb in the button, never "OK". A user tapping "OK" has not confirmed they understood.
- Dialogs never appear during recitation playback or on the Qibla screen. Both are attention-critical.
- Non-dismissible dialogs are permitted only for irreversible destructive confirmation and forced-upgrade blocks. Nothing else earns a modal trap.
- No dialog for information. If there is one button labelled "OK", it should be a snackbar.

---

## 4. Bottom sheets

The primary secondary surface in this product. Most of what other apps do in dialogs and menus happens here.

### 4.1 API

```dart
class QBottomSheet extends StatelessWidget {
  const QBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showHandle = true,
    this.isScrollControlled = false,
    this.initialSize = 0.5,
    this.minSize = 0.25,
    this.maxSize = 0.95,
    this.trailingAction,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isScrollControlled = false,
    bool useSafeArea = true,
  });
}

class QActionSheet extends StatelessWidget {
  const QActionSheet({
    super.key,
    required this.actions,            // List<QSheetAction>
    this.title,
  });
}
```

### 4.2 Specification

| Property | Value |
| --- | --- |
| Radius | 28dp top corners only, using BorderRadiusDirectional |
| Handle | 32 x 4dp, outlineVariant, 12dp top margin |
| Max width | 640dp, centred on tablet and desktop |
| Padding | 16dp horizontal, 8dp top, safe-area bottom plus 16dp |
| Enter | Slide from bottom, q.motion.page 350ms, decelerate |

### 4.3 Best practices

- The verse action sheet is the single most-used surface in the app. It must open in under 100ms and never wait on a network call to render.
- Sheets are reachable. Primary actions sit in the top half; destructive actions at the bottom, separated by a divider.
- Always safe-area aware at the bottom. A sheet action under the home indicator is untappable.
- A sheet taller than 50 percent of the screen must be draggable and scroll-controlled.
- No sheet inside a sheet. Replace the content of the existing sheet instead, with a directional slide.
- Keyboard-aware: use viewInsets padding so a text field inside a sheet is never covered.

---

## 5. Snackbars

### 5.1 API

```dart
class QSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    QFeedbackTone tone = QFeedbackTone.neutral,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    String? traceId,
  });

  static void showUndo({
    required BuildContext context,
    required String message,
    required VoidCallback onUndo,
  });
}
```

### 5.2 Specification

| Property | Value |
| --- | --- |
| Surface | inverseSurface |
| Text | onInverseSurface, body.medium |
| Action label | inversePrimary, button.medium |
| Radius | q.shape.sm 8 |
| Max width | 560dp |
| Position | Above bottom navigation, never over it |
| Duration | 4s default, 6s with an action, 10s for errors with a trace ID |

### 5.3 Best practices

- One snackbar at a time. A new one replaces the old immediately rather than queueing; a queue means the user reads feedback for an action three taps ago.
- Undo instead of confirm. Deleting a bookmark shows a snackbar with Undo. It does not open a dialog first. Reversible actions should never interrupt.
- Snackbars never carry critical information. They are transient and a user may miss them entirely.
- Error snackbars carry a copyable trace ID in caption.mono.
- Never used for success on worship actions. Logging a prayer shows an inline state change, not a toast congratulating the user.

---

## 6. Chips

### 6.1 API

```dart
enum QChipVariant { assist, filter, input, suggestion }

class QChip extends StatelessWidget {
  const QChip({
    super.key,
    required this.label,
    this.variant = QChipVariant.filter,
    this.isSelected = false,
    this.onPressed,
    this.onDeleted,
    this.leadingIcon,
    this.avatar,
  });
}

class QChipGroup extends StatelessWidget {
  const QChipGroup({
    super.key,
    required this.chips,
    this.multiSelect = false,
    this.scrollable = true,
  });
}
```

### 6.2 Specification

| Property | Value |
| --- | --- |
| Height | 32dp, wrapped in a 48dp target |
| Radius | q.shape.sm 8 |
| Padding | 12dp horizontal, 8dp with a leading icon |
| Text | label.large |
| Unselected | surfaceContainerHigh fill, outline border |
| Selected | secondaryContainer fill, no border, check icon leading |

### 6.3 Best practices

- Selected chips show a check icon, not colour alone. Colour-only selection fails for the 1 in 12 users with a colour vision deficiency.
- Filter chip rows scroll horizontally and never wrap to a third line.
- Chip labels never truncate. If a label is too long, the taxonomy is wrong.
- Never used for navigation. Chips filter or input; a chip that navigates is a mislabelled button.

---

## 7. Badges

### 7.1 API

```dart
enum QBadgeStyle { dot, count, label }

class QBadge extends StatelessWidget {
  const QBadge({
    super.key,
    required this.child,
    this.style = QBadgeStyle.dot,
    this.count,
    this.label,
    this.tone = QFeedbackTone.error,
    this.maxCount = 99,
  });
}

class QStatusBadge extends StatelessWidget {
  const QStatusBadge({
    super.key,
    required this.label,
    required this.tone,
    required this.icon,               // required, never colour alone
  });
}
```

### 7.2 Specification

| Style | Size | Content |
| --- | --- | --- |
| dot | 8dp circle | none |
| count | 16dp min, pill | label.small, tabular figures, 99+ overflow |
| label | 20dp, pill | label.small |

### 7.3 Best practices

- Badges never animate, pulse or bounce. A pulsing badge is an attention grab, and in this product it would be an attention grab on worship content.
- Count badges use tabular figures. Proportional digits make a badge change width as a counter ticks.
- No badge on premium features. Commerce does not decorate worship paths (P4).
- QStatusBadge requires an icon. A hadith grading or a sync state must never be conveyed by colour alone.
- Badge content is announced by screen readers as part of the parent semantics, not as a separate node.

---

## 8. Switches

### 8.1 API

```dart
class QSwitch extends StatelessWidget {
  const QSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });
}

class QSwitchTile extends StatelessWidget {
  const QSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.leadingIcon,
  });
}
```

### 8.2 Specification

| Property | Value |
| --- | --- |
| Track | 52 x 32dp, fully rounded |
| Thumb off | 16dp, outline colour |
| Thumb on | 24dp, onPrimary on a primary track |
| Icon in thumb | Check when on. Required, not decorative. |
| Motion | 150ms, q.easing.standard |
| RTL | Track and thumb mirror. Off is always at the start edge. |

### 8.3 Best practices

- The check icon in the on-thumb is mandatory. Track colour alone does not communicate state to colour-blind users, and M3's default switch is a known accessibility complaint.
- Switches apply immediately. No Save button on a settings screen with switches.
- The whole tile is the tap target, not just the switch.
- Never used for destructive or irreversible settings. Deleting downloads uses a button with confirmation.
- Switch labels state what is on, never a negative. "Show transliteration" not "Hide transliteration".
- In RTL the off position is at the start edge, which is the right side. This mirrors automatically and must be verified in goldens.

---

## 9. Checkboxes

### 9.1 API

```dart
class QCheckbox extends StatelessWidget {
  const QCheckbox({
    super.key,
    required this.value,              // bool? - null is indeterminate
    required this.onChanged,
    this.tristate = false,
    this.semanticLabel,
  });
}

class QCheckboxTile extends StatelessWidget {
  const QCheckboxTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });
}
```

### 9.2 Specification

| Property | Value |
| --- | --- |
| Box | 18dp, 2dp border, q.shape.xs 4 radius |
| Target | 48 x 48dp |
| Checked | primary fill, onPrimary check glyph |
| Indeterminate | primary fill, onPrimary horizontal bar |
| Motion | 150ms fill, check draws over 100ms |

### 9.3 Best practices

- Checkbox for multi-select, switch for a setting that takes effect immediately. Confusing the two is the most common control-selection error.
- Tristate is used only for parent nodes in a hierarchy, for example selecting a whole juz where some surahs are already downloaded.
- Checkbox lists always have a select-all affordance when longer than 8 items.
- Label text is always tappable.

---

## 10. Radio buttons

### 10.1 API

```dart
class QRadioGroup<T> extends StatelessWidget {
  const QRadioGroup({
    super.key,
    required this.value,
    required this.options,            // List<QRadioOption<T>>
    required this.onChanged,
    this.title,
  });
}

class QRadioOption<T> {
  const QRadioOption({
    required this.value,
    required this.label,
    this.description,
    this.trailing,
  });
}
```

### 10.2 Best practices

- Radio buttons are only ever exposed through QRadioGroup. A loose radio with no group has no semantics and no keyboard traversal.
- Two to seven options. Above seven use a dropdown; below two the control is unnecessary.
- Selection applies immediately. No Apply button.
- The description line matters here more than in most products. Prayer calculation methods (MWL, ISNA, Umm al-Qura, Karachi) are meaningless as bare acronyms; each option carries a plain-language description of the region and convention it suits.
- Radio groups never scroll horizontally. Vertical only, so labels have room in every locale.

---

## 11. Progress indicators

### 11.1 API

```dart
class QLinearProgress extends StatelessWidget {
  const QLinearProgress({
    super.key,
    this.value,                       // null == indeterminate
    this.label,
    this.detail,
    this.tone = QFeedbackTone.neutral,
  });
}

class QCircularProgress extends StatelessWidget {
  const QCircularProgress({
    super.key,
    this.value,
    this.size = QSize.medium,
    this.strokeWidth,
  });
}

class QMasteryRing extends StatelessWidget {
  const QMasteryRing({
    super.key,
    required this.progress,           // 0.0 - 1.0
    required this.label,
    this.size = 96,
  });
}

class QSkeleton extends StatelessWidget {
  const QSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.radius,
  });
}
```

### 11.2 The three-tier rule

| Duration | Component |
| --- | --- |
| Under 300ms | Nothing |
| 300ms to 3s | QSkeleton matching the final layout |
| Over 3s | QLinearProgress with a label and detail line |

### 11.3 Best practices

- Determinate wherever the total is knowable. Downloads, exports and Hifz recompute all know their totals; an indeterminate spinner in those cases is laziness.
- QLinearProgress with a label always states what is happening and whether the user can leave the screen.
- Never a full-screen spinner in the reader. The page frame and verse ornaments render first.
- QSkeleton shape-matches exactly. A mismatched skeleton causes a reflow on load, which is worse than no skeleton.
- Shimmer becomes a static fill under reduced motion.
- QMasteryRing animates on value change only, never on screen entry.

---

## 12. Search bars

### 12.1 API

```dart
class QSearchBar extends StatelessWidget {
  const QSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText,
    this.onSubmitted,
    this.onClear,
    this.leading,
    this.trailing,
    this.autofocus = false,
    this.debounce = const Duration(milliseconds: 250),
  });
}

class QSearchResultTile extends StatelessWidget {
  const QSearchResultTile({
    super.key,
    required this.result,
    required this.query,              // for match highlighting
    required this.onTap,
  });
}
```

### 12.2 Specification

| Property | Value |
| --- | --- |
| Height | 56dp |
| Radius | q.shape.full |
| Fill | surfaceContainerHigh |
| Text | body.large |
| Leading | Search icon, 24dp |
| Trailing | Clear icon when non-empty, voice input where available |
| Debounce | 250ms |

### 12.3 Best practices

- Text direction follows content, not locale. A user in an English UI typing Arabic must see the field flip to RTL as they type. This is the single most-missed behaviour in bilingual search fields.
- Diacritic-insensitive matching. A user typing unvocalised Arabic must match vocalised text; otherwise Quranic search is unusable for most people.
- Query performance under 300ms for a 3-character query, from local FTS5. Search never waits on the network.
- Match highlighting uses a background tint, never bold. Synthetic bold on Arabic is banned, and real bold changes the glyph shapes users are scanning for.
- Empty query shows recent searches and suggestions, not a blank screen.
- Never autofocus on a screen the user did not navigate to for the purpose of searching. An unrequested keyboard covering the mushaf is hostile.

---

## 13. Segmented controls

### 13.1 API

```dart
class QSegmentedControl<T> extends StatelessWidget {
  const QSegmentedControl({
    super.key,
    required this.value,
    required this.segments,           // List<QSegment<T>>
    required this.onChanged,
    this.size = QSize.medium,
  });
}

class QSegment<T> {
  const QSegment({
    required this.value,
    required this.label,
    this.icon,
  });
}
```

### 13.2 Specification

| Property | Value |
| --- | --- |
| Height | 40dp medium, 32dp small |
| Radius | q.shape.full outer, inner segments inherit |
| Track | surfaceContainerHigh |
| Selected | secondaryContainer, plus a check icon when 3 or fewer segments |
| Motion | Selection indicator slides 250ms, q.easing.standard |
| Segments | 2 to 4. Above 4, use chips or a dropdown. |

### 13.3 Best practices

- Used for view mode, never for filtering. Reader display mode (Arabic / Translation / Both) is the canonical case.
- Segment labels are one word each. Long labels in Arabic or German break the equal-width model, and equal width is what makes the control readable.
- Selection is instant, with no confirmation.
- The sliding indicator mirrors in RTL. Verified in goldens because a hard-coded Tween on x is the classic failure here.
- Never more than one segmented control visible at a time.

---

## 14. Dropdowns

### 14.1 API

```dart
class QDropdown<T> extends StatelessWidget {
  const QDropdown({
    super.key,
    required this.value,
    required this.items,              // List<QDropdownItem<T>>
    required this.onChanged,
    this.label,
    this.hint,
    this.errorText,
    this.isSearchable = false,
    this.size = QSize.medium,
  });
}

class QDropdownItem<T> {
  const QDropdownItem({
    required this.value,
    required this.label,
    this.description,
    this.icon,
    this.isEnabled = true,
  });
}
```

### 14.2 Specification

| Property | Value |
| --- | --- |
| Field height | 56dp |
| Radius | q.shape.sm 8 |
| Fill | surfaceContainerHigh |
| Border | 1dp outline, 2dp primary on focus, 2dp error on error |
| Menu | Bottom sheet on compact, anchored menu on expanded |
| Search threshold | Automatic above 10 items |

### 14.3 Best practices

- On phones a dropdown opens a bottom sheet, not a floating menu. Anchored menus are unreachable at the top of a large screen and clip badly with the keyboard open.
- Above 10 items the sheet gains a search field automatically. Reciter selection has 30-plus entries and translation selection has 25-plus; both are unusable without search.
- Selected item is marked with a check at the end edge, and the sheet opens scrolled to it.
- Descriptions are used wherever the label is an acronym or a proper noun the user may not recognise: calculation methods, madhhab for Asr, reciter styles.
- Disabled items state why in their description. A greyed-out reciter with no explanation reads as a bug; "Requires download" reads as an instruction.
- Never used for two options. Two options is a segmented control or a switch.

---

## 15. Component inventory and structure

```
lib/design_system/
  theme/          build_theme.dart, q_colors.dart, q_typography.dart,
                  q_spacing.dart, q_shape.dart, q_motion.dart, q_elevation.dart
  primitives/     q_icon.dart, q_text.dart, q_tap_target.dart
  components/     q_button.dart, q_card.dart, q_dialog.dart, q_bottom_sheet.dart,
                  q_snackbar.dart, q_chip.dart, q_badge.dart, q_switch.dart,
                  q_checkbox.dart, q_radio.dart, q_progress.dart,
                  q_search_bar.dart, q_segmented_control.dart, q_dropdown.dart
  domain/         q_ayah_card.dart, q_mushaf_page.dart, q_prayer_row.dart,
                  q_tasbih_counter.dart, q_audio_bar.dart, q_qibla_compass.dart,
                  q_hifz_unit_tile.dart, q_mastery_ring.dart
  feedback/       q_empty_state.dart, q_error_state.dart, q_skeleton.dart
```

The design system package has no dependency on any feature module, and no feature module imports Material directly. Both are enforced by import lints.

---

## 16. Verification

| Check | Blocks |
| --- | --- |
| No Material widget imported outside design_system/ | Merge |
| No hard-coded Color, TextStyle, EdgeInsets.all with literal, or Duration | Merge |
| No EdgeInsets.only(left:/right:), Alignment.centerLeft, TextAlign.left | Merge |
| Every interactive component has a 48dp minimum target | Widget test |
| Every component has 24 goldens (3 themes x 2 directions x 4 scales) | Merge |
| No `enabled` parameter on any component | Lint |
| Every icon-only control has a non-null semanticLabel | Widget test |
| Contrast of every rendered state meets the floors in COLOR_SYSTEM.md | Golden analysis |

---

## 17. Four positions worth arguing about

1. Requiring a check icon on switches and selected chips will be called visual noise. It is the difference between a control that works for everyone and one that works for trichromats. Tajweed colouring already forces us to take this seriously; the rest of the system should be consistent with it.
2. Banning the `enabled` parameter will annoy engineers migrating Material code. Two sources of truth for one state is the most reliable way to ship a button that looks tappable and does nothing.
3. Bottom sheets instead of anchored dropdown menus costs a frame of animation and some perceived snappiness on tablets. On phones it is unambiguously correct, and one behaviour across form factors is worth more than a marginally faster tablet interaction.
4. 24 goldens per component is a large number and will slow CI. Twenty-four components at 24 goldens is 576 comparisons before domain widgets. It is also the only mechanism that catches RTL mirroring failures and AMOLED contrast regressions before users do.
