# Quran One - UI Kit Specification

Status: Draft 1
Owner: UI Engineering
Depends on: DESIGN_SYSTEM.md, COLOR_SYSTEM.md, TYPOGRAPHY_SYSTEM.md, VISUAL_LANGUAGE.md, COMPONENT_LIBRARY.md, NAVIGATION.md, MOTION_SYSTEM.md, ACCESSIBILITY.md

---

## 0. The organising idea

Seventeen screens are specified below. They are **not** seventeen layouts. They are **six archetypes** plus one deliberate exception.

| Archetype | Scaffold | Screens |
| --- | --- | --- |
| A1 Immersive | `QImmersiveScaffold` | Splash, Onboarding, Qibla, Player |
| A2 Hub | `QHubScaffold` | Home, Premium, Profile |
| A3 Index | `QIndexScaffold` | Quran, Hadith, Azkar, Bookmarks, Notifications |
| A4 Reading | `QReadingScaffold` | Reader, Hadith detail, Azkar session |
| A5 Form | `QFormScaffold` | Login, Register |
| A6 Settings | `QSettingsScaffold` | Settings, Prayer settings, Profile edit |

Search fits no archetype and has its own template. That is a decision, not an oversight: search is the only surface whose layout is driven entirely by result shape rather than by a fixed information hierarchy.

If a new screen cannot declare an archetype, that is a signal to challenge the screen, not to add a seventh archetype.

---

## 1. Spacing rules

### 1.1 The scale

`0, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64`

A custom lint rejects any `EdgeInsets` or `SizedBox` literal that is not on this scale.

### 1.2 Aliases - always the alias, never the number

| Alias | Value | Use |
| --- | --- | --- |
| `inline.tight` | 4 | Icon to its own label |
| `inline` | 8 | Between adjacent inline elements |
| `stack.tight` | 8 | Title to subtitle |
| `stack` | 16 | Between siblings in a group |
| `stack.loose` | 24 | Between groups in a section |
| `section` | 32 | Between sections |
| `gutter` | 16 / 24 / 24 | Page horizontal padding by breakpoint |

Writing `16` instead of `q.space.stack` is a review rejection. The number will change; the intent will not.

### 1.3 Page padding

| Breakpoint | Horizontal | Notes |
| --- | --- | --- |
| Compact (<600) | 16 | |
| Medium (600-839) | 24 | |
| Expanded (840+) | 24 | Content capped at 840dp, centred |
| Reading canvas | `1.6em` clamped 20-96dp | Scales with the Arabic size slider |
| Reading vertical | `2.0em` | Same reason |

Em-based reading margins are the single most important spacing decision in the product. Fixed dp margins look correct at 26sp and absurd at 48sp.

### 1.4 The five rules

1. **Vertical rhythm is owned by the parent.** Lists use `separatorBuilder`. Children never carry their own vertical margins.
2. **Nested radius**: `inner = outer - padding`. A 16dp-radius card with 12dp padding contains 4dp-radius children.
3. **Never double-pad.** If the scaffold applies the gutter, the child must not.
4. **Bottom padding auto-includes** the navigation bar height and the safe area. No screen computes this itself.
5. **Spacing does not scale with text.** Text scales; the grid does not. Otherwise a 200% user gets a page that is 90 percent whitespace.

### 1.5 Grid

| Breakpoint | Columns | Gutter | Margin | Max width |
| --- | --- | --- | --- | --- |
| Compact | 4 | 16 | 16 | - |
| Medium | 8 | 24 | 24 | - |
| Expanded | 12 | 24 | 24 | - |
| Large | 12 | 24 | auto | 1440 |

---

## 2. QScaffold

Every archetype wraps one primitive.

```dart
enum QScreenState { loading, empty, error, offline, content }

class QScaffold extends StatelessWidget {
  const QScaffold({
    required this.body,
    this.appBar,
    this.floatingAction,
    this.state = QScreenState.content,
    this.emptyState,
    this.errorState,
    this.maxContentWidth = 840,
    this.applyGutter = true,
    this.scrollable = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingAction;
  final QScreenState state;
  final QEmptyState? emptyState;
  final QErrorState? errorState;
  final double maxContentWidth;
  final bool applyGutter;
  final bool scrollable;
}
```

One state enum per screen is what makes the section 19 state matrix verifiable in CI. A screen that models loading with a nullable field instead of the enum cannot be tested by the matrix test and will not pass review.

### 2.1 Ownership

| Scaffold | Gutter | Bottom inset | Max width | Scroll |
| --- | --- | --- | --- | --- |
| `QImmersiveScaffold` | No | Safe area only | None | Rarely |
| `QHubScaffold` | Yes | Nav + safe area | 840 | Yes |
| `QIndexScaffold` | Yes | Nav + safe area | 840 | Yes (slivers) |
| `QReadingScaffold` | Em-based | Safe area | 720 | Yes |
| `QFormScaffold` | Yes | Keyboard + safe area | 480 | Yes |
| `QSettingsScaffold` | Inset dividers | Nav + safe area | 840 | Yes |

---

## 3. Splash (A1)

Native only. There is no Dart splash screen.

- `flutter_native_splash`, static mark, theme-aware background including AMOLED `#000000`
- 200ms cross-fade into the first route
- No animation, no logo reveal, no progress indicator

A Dart splash screen exists only to hide a slow start. The correct fix is the 2.0s cold-start budget, not a distraction.

---

## 4. Onboarding (A1)

Four static screens. Padding 24 horizontal, 48 top, 32 bottom.

```
illustration 240x180
  section (32)
headline  - headline.small
  stack.tight (8)
body      - body.medium, max 3 lines
  Spacer()
4-dot page indicator
  stack (16)
primary action (full width, 52dp)
  inline (8)
skip (text button)
```

- Shared-axis X, direction-aware
- Only screen 3 is interactive: it captures `learning_level`
- No account required to finish

---

## 5. Login (A5)

Max width 480dp, centred above 600dp.

```
header (title.large + body.medium)
  section
email field
  stack
password field
  stack.tight
forgot password (end-aligned text button)
  stack.loose
primary action
  section
divider with "or"
  stack.loose
social buttons (stacked, full width)
  section
footer: "No account? Register"
  stack.loose
"Continue without an account"
```

Rules:

- **"Continue without an account" sits below the footer, always visible.** Login exists for sync, not for access. This is principle P3.
- Persistent labels, never placeholder-only
- Paste is never blocked in the password field
- Keyboard-aware scroll keeps the focused field and the primary action visible

---

## 6. Register (A5)

Name, email, password, confirm password.

- Strength bar carries **a text label**, never colour alone
- Requirements checklist is persistent, not revealed on failure
- Consent checkbox unchecked by default
- **"Create account" is never disabled.** Pressing it with invalid input focuses the first invalid field and announces the reason. A disabled button that does not say why is a dead end for screen reader users.
- A plain-language note explains what is stored and what is not

---

## 7. Home (A2)

Order is fixed:

1. Greeting plus Hijri date
2. `QPrayerCountdownCard` - always first, tallest element, `primaryContainer`
3. `QContinueCard` - **absent on first run**, not rendered as an empty state
4. `QHifzSummaryCard`
5. `QToolTile` grid 2x3: Qibla, Tasbih, Azkar, Hadith, Dua, Khatmah
6. Verse of the day

Rules:

- The avatar at the end edge of the app bar is the entire settings entry point
- Inline search field, not an icon
- `section` between blocks, `stack` within them
- Grid is 2 / 3 / 6 columns by breakpoint
- **Nothing animates on entry.** The countdown counts down, never up.
- Offline rendering is byte-identical to online

An absent "Continue reading" card is better than an empty one. A first-run user has nothing to continue, and telling them so is a reproach.

---

## 8. Quran (A3)

Tabs: Surah, Juz, Page, Saved. Sticky search below the tabs.

Surah row anatomy:

```
[octagram numeral frame 40dp]  inline  Latin name (title.medium)
                                       meaning (body.small, muted)
                        -- Spacer --
                                       Arabic name (arabic UI face)
                                       ayah count (caption)
```

- Page tab: 3-column grid, 64dp cells
- Alphabet rail on the end edge
- `LocaleStringAttribute` on every Arabic name so the screen reader switches voice
- Opening a surah pushes the reader as a **root route**, above the shell

---

## 9. Prayer (A2/A3 hybrid)

- Hero countdown plus calculation-method chip
- Five `QPrayerRow`s
- Sunnah toggle
- Three actions: calendar, athan settings, location

Row states: passed, current, next, upcoming. Each carries an icon and a label, never tint alone. Times use tabular figures. The current row carries a start-edge marker.

**This screen structurally cannot show a network error.** Prayer times are computed on device by the astronomical engine. There is no request to fail.

---

## 10. Qibla (A1)

- 280dp compass; the rose does not mirror in RTL
- Three accuracy tiers, each with an icon and text
- **Manual heading entry fallback** for devices without a usable magnetometer (SC 2.5.4)
- Semantics announce bearing plus a clock-face position, throttled to 2s
- Low-pass filter on the sensor stream; no spring animation

---

## 11. Hadith (A3 to A4)

Collection, then book, then list, then detail.

- Reference rendered in `caption.mono` and copyable
- Arabic body in `notoNaskhReading` at 8:1 contrast, line height 1.80
- **Grading is always a text label** (Sahih, Hasan, Daif), never a coloured dot

---

## 12. Azkar (A3 to A4)

Six sets. Session layout:

- 96dp counter as the primary target
- `mediumImpact` haptic per count
- Auto-advance with a 400ms pause
- Swipe plus explicit previous/next buttons
- Screen stays awake for the session duration
- **Quiet completion.** No confetti. The text reads "Morning azkar complete."

---

## 13. Settings (A6)

Nine groups: Account, Reading, Audio, Prayer, Appearance, **Accessibility**, Storage, Privacy, About.

- Accessibility is a top-level group, not buried inside Appearance
- 56dp rows, inset dividers
- **No Save button anywhere.** Every change applies immediately.
- Trailing text shows the current value
- Plain-language descriptions for MWL, ISNA and Umm al-Qura
- Any picker with more than 10 items becomes a searchable sheet
- Tajweed colouring is off by default

---

## 14. Premium (A2)

- Opens with a sentence explaining what subscription revenue funds
- Three tiers; the annual option is marked "best value" with a label, not a colour
- Regional pricing is applied silently, never announced
- **The free column is complete and prominent.** All worship features are permanently free.
- Anonymous waqf tier
- Restore purchases always visible

Constraints:

- **Unreachable from any worship path.** Enforced by a route-graph test.
- No lock badges anywhere else in the app
- No countdown timers, no fake scarcity, no pre-selected upsell

---

## 15. Profile (A2) and Notifications (A3)

Profile statistics are descriptive, never comparative: "You've read 27 of the last 30 days." Never "You missed 3 days."

Notifications:

- Types: prayer, review due, content update, account
- Unread is marked by a start-edge bar **and** a dot - two carriers
- Swipe to dismiss, with an overflow menu alternative
- Empty state reads "Nothing new."

---

## 16. Search (own template)

Route-based: `/search?q=&scope=`.

- Under 3 characters: recent searches and suggested scopes
- 3 or more: grouped results with sticky section headers
- **Matches are highlighted with a background tint, never bold.** Bolding Arabic changes glyph shapes.
- Spelling tolerance; "2:255" is recognised as a reference
- Field direction follows the typed content, not the UI locale
- Diacritic-insensitive matching
- Local FTS5, results under 300ms

---

## 17. Bookmarks (A3)

- Three sub-filters: All, Highlights, Notes
- Row: reference, first clause, highlight swatch, timestamp
- Sort, filter and bulk select
- **Swipe to delete shows an Undo snackbar, not a confirmation dialog**
- Passive empty copy
- Highlight colours use non-semantic names (Saffron, Sage, Sky, Rose, Lilac)

---

## 18. Player (A1)

Mini player: 64dp, docked above the bottom navigation bar, hero-transitions to the full player.

Full player regions:

```
240dp artwork / calligraphic plate
  section
reference (title.large)
reciter (body.medium, muted)
  stack.loose
scrubber (tabular figures both ends)
  stack
transport row (72dp play, 48dp others)
  section
speed | repeat | sleep | download
  stack.loose
queue sheet handle
```

- **Plus and minus 5 second buttons are provided as an alternative to scrubbing** (SC 2.5.7)
- Magic Tap and hardware media keys are honoured
- Audio survives all navigation, including reader entry and exit
- Lock screen and CarPlay metadata are populated
- Nothing else in the app animates during recitation playback

---

## 19. Cross-cutting state matrix

All 17 screens x 5 states. A single test instantiates every template in every state at 200% text scale and asserts no overflow.

**Twelve of the seventeen screens are byte-identical offline.** The five that are not: Premium, Profile, Notifications, Search (remote scope only), Player (undownloaded audio only).

---

## 20. Responsive behaviour

- Reading canvas never exceeds 720dp
- Measure held at 60-75 characters
- Master-detail only above 840dp
- The rail replaces the bottom bar; the two never appear together

---

## 21. Structure

```
lib/ui/
  scaffolds/  q_scaffold, q_immersive, q_hub, q_index, q_reading, q_form, q_settings
  templates/  seventeen screen templates
  states/     q_loading_state, q_empty_state, q_error_state, q_offline_state
```

Templates are layout-only. Data is injected via Riverpod at the route level, which is what makes every template golden-testable with fixtures and no providers.

---

## 22. Verification

| Check | Gate |
| --- | --- |
| Every screen declares an archetype | Review |
| Five states render without overflow at 200% | CI |
| No off-scale `EdgeInsets` literal | Lint |
| No template applies its own gutter | Lint |
| Goldens: 3 themes x 2 directions x 4 scales x 3 breakpoints | CI |
| Premium unreachable from worship routes | Route-graph test |
| No network provider read on first paint | CI |

---

## 23. Four positions worth arguing about

**1. "Continue without an account" will cost signup conversion.** It will. Requiring an account to read scripture is worse.

**2. Six archetypes constrain bespoke screens, deliberately.** A designer will eventually want a screen that fits none of them. The correct response is usually to challenge the screen.

**3. Home omits the "Continue reading" card on first run rather than showing an empty state.** Some will read this as an inconsistent layout. It is consistent with the copy doctrine.

**4. The premium route-graph test will eventually block a legitimate-looking PR.** That is the point. An invariant that never fires is not an invariant.
