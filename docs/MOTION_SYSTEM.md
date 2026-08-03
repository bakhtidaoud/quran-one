# Quran One - Motion System

Codename: Mizan. Companion to DESIGN_SYSTEM.md, VISUAL_LANGUAGE.md and NAVIGATION.md.

---

## 0. The posture

Most app motion is designed to be noticed. Ours is designed to be felt and forgotten.

Three rules generate almost everything below:

1. **No spring, no bounce, no overshoot, anywhere.** Playful physics is tonally wrong next to scripture, and overshoot on vocalised Arabic at 26sp is genuinely unpleasant - the diacritics smear.
2. **Quranic text never moves, scales, or fades as part of a transition.** Ever. It can be revealed; it cannot be animated.
3. **Motion clarifies a spatial relationship or it does not ship.** If an animation exists to look premium, it is decoration, and decoration on a worship surface is noise.

---

## 1. Tokens

### 1.1 Duration

| Token | ms | Use |
| --- | --- | --- |
| q.motion.instant | 50 | State colour changes, ripple onset |
| q.motion.short | 150 | Icon morphs, checkbox fill, button feedback |
| q.motion.medium | 250 | Selection indicators, cards, chips, snackbars |
| q.motion.long | 400 | Progress arcs, expanding surfaces |
| q.motion.page | 350 | Route transitions |
| q.motion.sheet | 350 | Bottom sheet enter |
| q.motion.sheetExit | 250 | Bottom sheet exit - exits are faster than entries |
| q.motion.extended | 600 | Onboarding reveals, first-run only |

Exits are consistently about 30 percent faster than entries. The user has already decided; making them wait for a symmetrical animation is making them wait for nothing.

### 1.2 Easing

| Token | Cubic-bezier | Flutter | Use |
| --- | --- | --- | --- |
| q.easing.standard | (0.2, 0, 0, 1) | Curves.easeInOutCubicEmphasized | On-screen movement, the default |
| q.easing.decelerate | (0, 0, 0, 1) | Curves.easeOutCubic | Elements entering the screen |
| q.easing.accelerate | (0.3, 0, 1, 1) | Curves.easeInCubic | Elements leaving the screen |
| q.easing.linear | - | Curves.linear | Progress fills, indeterminate loops only |

```dart
abstract final class QMotion {
  static const instant    = Duration(milliseconds: 50);
  static const short      = Duration(milliseconds: 150);
  static const medium     = Duration(milliseconds: 250);
  static const long       = Duration(milliseconds: 400);
  static const page       = Duration(milliseconds: 350);
  static const sheet      = Duration(milliseconds: 350);
  static const sheetExit  = Duration(milliseconds: 250);
  static const extended   = Duration(milliseconds: 600);
}

abstract final class QEasing {
  static const standard   = Cubic(0.2, 0.0, 0.0, 1.0);
  static const decelerate = Cubic(0.0, 0.0, 0.0, 1.0);
  static const accelerate = Cubic(0.3, 0.0, 1.0, 1.0);
  static const linear     = Curves.linear;
}
```

---

## 2. Page transitions

### 2.1 The RTL problem, stated plainly

A horizontal slide encodes direction, and direction is not stable across our locales. In English, forward slides content in from the end edge. In Arabic that same gesture means the opposite thing spatially, and hard-coded Offset(1.0, 0) tweens produce transitions that feel backwards to half our users.

Three options: mirror every slide manually (fragile), use directional offsets everywhere (better, still error-prone), or avoid encoding direction in the transition at all. We do the third wherever direction is not semantically meaningful.

### 2.2 The transition set

| Transition | Duration | Where |
| --- | --- | --- |
| Fade-through | 350ms | Branch switches, reader entry, search entry - anything with no parent/child relationship |
| Shared-axis Z | 350ms | Push into a child route: surah index to surah detail |
| Shared-axis X (directional) | 350ms | Onboarding pages, mushaf page turns |
| Fade | 250ms | Settings sub-pages, low-hierarchy navigation |
| None | 0ms | Tab switches within a screen (TabBarView handles the swipe) |

```dart
Widget qFadeThrough(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondary,
  Widget child,
) {
  return FadeThroughTransition(
    animation: animation,
    secondaryAnimation: secondary,
    fillColor: Theme.of(context).colorScheme.surface,
    child: child,
  );
}

Widget qSharedAxisZ(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondary,
  Widget child,
) {
  return SharedAxisTransition(
    animation: animation,
    secondaryAnimation: secondary,
    // Z axis: no lateral movement, therefore no RTL ambiguity.
    transitionType: SharedAxisTransitionType.scaled,
    fillColor: Theme.of(context).colorScheme.surface,
    child: child,
  );
}
```

Shared-axis Z (a subtle scale plus fade) is our default push transition precisely because it has no lateral component. It reads as depth, which is the actual relationship, rather than as lateral position, which is not.

### 2.3 The one place direction is mandatory

Mushaf page turns always advance RTL, in every locale, including English. The mushaf is right-to-left as a physical object. This is the mirror-exception documented in the design system and it is not negotiable.

```dart
// Page turn is ALWAYS RTL regardless of Directionality.
// This is the documented mirror exception - do not "fix" it.
final slideBegin = forward ? const Offset(-1, 0) : const Offset(1, 0);
```

No page curl, no shadow sweep, no paper texture. A 350ms slide with q.easing.standard. Curl effects cost frames, break at 120Hz, and look like a skeuomorphic app from 2012.

### 2.4 Route-level implementation

```dart
CustomTransitionPage<T> qPage<T>({
  required Widget child,
  required LocalKey key,
  QTransition transition = QTransition.fadeThrough,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: QMotion.page,
    reverseTransitionDuration: QMotion.medium,
    transitionsBuilder: transition.builder,
  );
}
```

---

## 3. Hero animations

### 3.1 Where heroes are used

Exactly three places. Heroes are expensive to get right and catastrophic when wrong.

| Source | Destination | What flies |
| --- | --- | --- |
| Mini audio player | Full audio player | Reciter artwork plus play control |
| Surah index tile | Surah detail header | The Latin surah name and number only |
| Hifz unit tile | Review session header | The mastery ring |

### 3.2 The Arabic constraint

**Arabic text never flies in a hero.**

When a Hero interpolates between two Text widgets of different sizes, Flutter scales the widget during flight and relays out at the destination. For Latin that reads as smooth. For vocalised Arabic it produces visible glyph reflow mid-flight - diacritic positions recompute at intermediate sizes and the text appears to shimmer and rewrite itself.

So: the surah hero carries the transliterated Latin name and the number. The Arabic name cross-fades in place at the destination over 200ms after the flight settles.

```dart
Hero(
  tag: 'surah-${surah.id}',
  flightShuttleBuilder: (_, animation, __, ___, ____) {
    // Fade between endpoints instead of scaling a single widget.
    // Scaling Arabic glyphs mid-flight causes diacritic reflow.
    return FadeTransition(
      opacity: animation,
      child: QSurahHeroContent(surah: surah, latinOnly: true),
    );
  },
  child: QSurahTile(surah: surah),
)
```

### 3.3 Hero rules

- Tags are globally unique and derived from stable IDs, never from list index.
- A hero never crosses a branch boundary - cross-branch flights land on a widget that may have been disposed.
- Maximum one hero per transition. Two simultaneous flights read as chaos at 350ms.
- Heroes are disabled entirely under reduced motion; the destination simply fades in.

---

## 4. Loading animations

### 4.1 The three tiers

| Duration | Treatment | Motion |
| --- | --- | --- |
| under 300ms | Nothing | - |
| 300ms to 3s | Skeleton | Shimmer sweep, 1400ms, q.easing.standard |
| over 3s | Determinate progress | Value tween 400ms, q.easing.standard |

### 4.2 Shimmer

```dart
class QSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final reduced = QMotionScope.of(context).reduced;
    final base = Theme.of(context).colorScheme.surfaceContainerHigh;

    if (reduced) {
      return DecoratedBox(
        decoration: BoxDecoration(color: base, borderRadius: radius),
        child: SizedBox(width: width, height: height),
      );
    }

    return RepaintBoundary(          // isolates the repaint to the skeleton
      child: AnimatedBuilder(
        animation: _controller,       // 1400ms, repeating, shared app-wide
        builder: (context, _) => ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            // Sweep follows text direction, not a hard-coded left-to-right.
            begin: AlignmentDirectional.centerStart.resolve(direction),
            end: AlignmentDirectional.centerEnd.resolve(direction),
            colors: [base, highlight, base],
            stops: _stopsFor(_controller.value),
          ).createShader(bounds),
          child: ColoredBox(color: base),
        ),
      ),
    );
  }
}
```

One shared AnimationController drives every skeleton on screen. Twenty skeletons with twenty controllers is twenty ticker callbacks per frame, and the phases desynchronise into visual noise.

### 4.3 Indeterminate indicators

Standard M3 circular indicator, Curves.linear, no customisation. Never full-screen, never in the reader. If a spinner is the only thing on screen, the tier logic was applied wrong.

### 4.4 Progress value changes

Determinate progress animates to its new value over 400ms rather than jumping - but never animates backwards. A download that recalculates its total and shows the bar retreating destroys trust in the number. If the total changes, the bar holds and the detail line updates.

---

## 5. Button feedback

| Layer | Spec |
| --- | --- |
| Ripple | M3 default, q.motion.instant onset, onPrimary at 12 percent |
| Press scale | None. No 0.96 press-down. |
| Hover (pointer) | Container tint +8 percent, 150ms |
| Focus | 2dp primary ring, 3.5:1 minimum, 150ms fade |
| Disabled | 200ms cross-fade to disabled colours |
| Haptic | selectionClick on tap-down, not tap-up |

No press-scale. Scaling a button on press is a common premium affectation that costs a layout pass on every tap, and on a device holding four live navigator branches those passes are visible in the frame graph. The ripple already confirms the touch.

Haptic fires on tap-down, not on completion. The user needs confirmation the touch registered, not confirmation the work finished - that is what the state change is for.

### 5.1 Loading transition

```dart
AnimatedSwitcher(
  duration: QMotion.short,
  switchInCurve: QEasing.decelerate,
  switchOutCurve: QEasing.accelerate,
  transitionBuilder: (child, animation) =>
      FadeTransition(opacity: animation, child: child),
  child: isLoading
      ? const QCircularProgress(size: QSize.small, key: ValueKey('loading'))
      : Text(label, key: const ValueKey('label')),
)
```

Wrapped in a width-preserving container so the button does not resize.

---

## 6. Card animations

| Event | Motion |
| --- | --- |
| Tap | Ripple only. No lift, no scale. |
| Selection | Border and tint cross-fade, 250ms |
| Insert into a list | Fade plus 8dp rise, 250ms q.easing.decelerate |
| Remove | Fade plus size collapse, 200ms q.easing.accelerate |
| Reorder | ReorderableListView default, 250ms |
| Expand (tafsir, hadith detail) | AnimatedSize 250ms plus content fade 150ms delayed 100ms |

### 6.1 QAyahCard - the strictest case

| Event | Motion |
| --- | --- |
| Playback starts | Background cross-fades to primaryContainer at 12 percent, 200ms |
| Playback advances | Background cross-fade only |
| Bookmark toggled | Icon FILL axis morph 200ms plus 1.0 to 1.12 to 1.0 icon scale |
| Highlight applied | Tint wipes in from the text start edge, 250ms |
| Selected | Persistent 3dp start-edge border fades in, 150ms |

The ayah text itself is completely static in all five cases. No scale, no colour animation on the glyphs, no position shift. A user following recitation is tracking specific words; moving them is disorienting in a way that is hard to articulate but immediately obvious in testing.

---

## 7. List animations

### 7.1 The position

**No entry stagger. Ever.**

Staggered list entry is the most requested and least defensible animation in mobile design. It looks impressive in a portfolio and it means every screen entry costs 300-500ms before content is readable. Users visit the surah index hundreds of times; delighting them once costs them 599 subsequent waits.

Lists appear. Immediately. Fully.

### 7.2 What is animated

| Event | Motion |
| --- | --- |
| Item inserted (bookmark added) | Fade plus size expand, 250ms q.easing.decelerate |
| Item removed | Fade plus size collapse, 200ms q.easing.accelerate |
| Swipe-to-dismiss | Follows the finger, 1:1, no easing while dragging |
| Dismiss commits | Slide out 200ms q.easing.accelerate plus collapse |
| Reorder | Standard drag, 250ms settle |
| Filter change | Cross-fade the whole list, 200ms - not per-item |
| Scroll | Platform physics, untouched |

Cross-fading the whole list on a filter change rather than animating individual items in and out is the right call: per-item diff animation on a 20-item filter change produces twenty simultaneous overlapping tweens, which reads as a glitch, not a transition.

```dart
AnimatedList(
  key: _listKey,
  initialItemCount: items.length,
  itemBuilder: (context, index, animation) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: QEasing.decelerate),
      child: FadeTransition(
        opacity: animation,
        child: QAyahCard(ayah: items[index]),
      ),
    );
  },
)
```

### 7.3 The reader list

The mushaf uses a ListView.builder with addRepaintBoundaries: true and zero item animation. Anything animating in a 604-page virtualised list is a dropped frame during scroll, and our budget is under 1 percent dropped frames on a 4GB Android device.

---

## 8. Dialogs

| Phase | Motion |
| --- | --- |
| Scrim in | Fade to 32 percent, 250ms q.easing.decelerate |
| Dialog in | Fade plus scale 0.92 to 1.0, 250ms q.easing.decelerate |
| Dialog out | Fade plus scale 1.0 to 0.96, 200ms q.easing.accelerate |
| Scrim out | Fade, 200ms |
| Barrier tap | Same as dismiss. No shake. |

Scale starts at 0.92, not 0.8. A dramatic scale-up reads as an alert, and most of our dialogs are quiet confirmations.

Rejected dismissal never shakes. A non-dismissible dialog tapped on its barrier simply does nothing. Shake is a punitive animation borrowed from password fields, and using it on a religious app confirmation dialog is tonally indefensible.

---

## 9. Bottom sheets

| Phase | Motion |
| --- | --- |
| Enter | Slide from bottom, 350ms q.easing.decelerate |
| Exit | Slide down, 250ms q.easing.accelerate |
| Scrim | Fade 0 to 32 percent over the same 350ms |
| Drag | 1:1 with the finger, no easing, no resistance |
| Release above threshold | Settle to nearest snap, 250ms q.easing.standard |
| Release below 40 percent | Dismiss, 200ms q.easing.accelerate |
| Content swap (sheet to sub-sheet) | Cross-fade 200ms plus AnimatedSize 250ms |

### 9.1 The verse action sheet

The single most-used surface in the app. It must be open and interactive in under 100ms of perceived latency, which means the widget tree is prebuilt and cached - the animation is the only work happening at open time.

```dart
// Prebuilt once per reader session, not per invocation.
final verseSheetProvider =
    Provider.autoDispose<Widget>((ref) => const QVerseActionSheet());
```

Drag tracks the finger exactly. No rubber-banding, no resistance curve. Rubber-banding on a sheet feels like the app is arguing with you.

---

## 10. Pull to refresh

### 10.1 Where it exists

| Surface | Pull to refresh |
| --- | --- |
| Sync status / account | Yes |
| Hadith collections (remote) | Yes |
| Download manager | Yes |
| Prayer times | No - computed locally, nothing to refresh |
| Mushaf reader | No - conflicts with vertical scroll and there is no remote source |
| Surah index | No - static content |
| Hifz review queue | No - computed locally |

Three of eleven scrollable surfaces have it. A pull-to-refresh on a screen with no remote source is a lie: it spins, achieves nothing, and teaches users the gesture is decorative.

### 10.2 Spec

Standard M3 indicator, 64dp trigger, q.easing.decelerate, lightImpact haptic at the threshold crossing, not at release - so the user knows they can let go. Minimum 400ms visible even if the refresh returns instantly, because a spinner that vanishes in 30ms reads as a failure.

---

## 11. Splash

### 11.1 The position

**There is no splash animation. The splash screen is a static native image that hands off to the first frame.**

Our cold-start budget is 2.0 seconds. An animated splash either runs during the work, adding CPU contention to the most contended moment in the app lifecycle, or runs after the work, deliberately delaying a user who could already be reading.

Every animated splash is a company showing you its logo instead of showing you your content.

### 11.2 What ships

| Layer | Content |
| --- | --- |
| Native splash | Static: app mark, centred, on theme background. flutter_native_splash, Android 12+ SplashScreen API. |
| Handoff | Native splash fades out over 200ms into the first frame |
| First frame | Home, with skeletons if data is not ready |

Theme-aware from the OS setting, so a dark-mode user at Fajr never gets a white flash. That flash is the single most complained-about splash behaviour in prayer apps, because people open them in the dark.

```yaml
flutter_native_splash:
  color: "#FBF8F3"
  color_dark: "#14161A"
  image: assets/splash/mark_light.png
  image_dark: assets/splash/mark_dark.png
  android_12:
    color: "#FBF8F3"
    color_dark: "#000000"      # AMOLED users get true black
    icon_background_color: "#FBF8F3"
```

No progress bar on the splash. If startup is slow enough to need one, the fix is startup, not the indicator.

---

## 12. Accessibility

### 12.1 Reduced motion is not "no motion"

Vestibular triggers are large-displacement and parallax motion, not opacity change. Removing all animation makes state changes instantaneous and harder to follow, which helps nobody.

| Category | Normal | Reduced |
| --- | --- | --- |
| Page transitions | Fade-through / shared-axis | Cross-fade, 150ms |
| Hero flights | Full flight | Disabled - destination fades in |
| Slide-ins (sheets, snackbars) | Slide | Fade in place |
| Scale (dialogs) | 0.92 to 1.0 | Fade only |
| Shimmer | Sweeping | Static fill |
| Illustration ambient motion | Slow rotate | Disabled |
| Indeterminate spinners | Rotate | Retained - conveys ongoing work, small displacement |
| Determinate progress | Tween | Retained - conveys real information |
| Colour and opacity changes | 150-250ms | Retained |
| Page turn | Slide | Cross-fade |

### 12.2 Two switches, one resolver

```dart
class QMotionScope extends InheritedWidget {
  const QMotionScope({super.key, required this.reduced, required super.child});
  final bool reduced;

  static QMotionScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<QMotionScope>()!;

  @override
  bool updateShouldNotify(QMotionScope old) => old.reduced != reduced;
}

bool resolveReducedMotion(BuildContext context, WidgetRef ref) {
  // OS setting OR our in-app setting. Either one wins.
  final os = MediaQuery.disableAnimationsOf(context);
  final app = ref.watch(settingsProvider.select((s) => s.reduceMotion));
  return os || app;
}

Duration qDuration(BuildContext context, Duration normal) =>
    QMotionScope.of(context).reduced
        ? Duration(milliseconds: math.min(normal.inMilliseconds, 150))
        : normal;
```

We ship our own switch as well as honouring the OS one because the OS setting is global, and a user may want a lively phone and a still Quran app.

### 12.3 Non-negotiables

- No animation longer than 5 seconds and no infinite loop outside indeterminate progress (WCAG 2.2.2).
- Nothing flashes more than 3 times per second (WCAG 2.3.1). Nothing in this system flashes at all.
- Animation is never the sole indicator of a state change - every animated transition has a static end state that reads correctly on its own.
- All motion is suspended during active recitation playback except the ayah background cross-fade.

---

## 13. Performance

### 13.1 Budget

| Metric | Target |
| --- | --- |
| Frame budget | 16.6ms at 60Hz, 8.3ms at 120Hz |
| Dropped frames during transitions | under 1 percent on Pixel 4a / Galaxy A14 |
| Simultaneous AnimationControllers | 6 or fewer |
| Animated widgets per frame | 20 or fewer |

### 13.2 Rules

| Do | Do not |
| --- | --- |
| FadeTransition | AnimatedOpacity on large subtrees |
| SlideTransition | AnimatedPositioned |
| AnimatedBuilder with a child parameter | Rebuilding the subtree every tick |
| RepaintBoundary around animated regions | Letting repaints propagate to siblings |
| One shared controller for repeating effects | One controller per instance |
| Transform | Animating layout properties |

Never animate a property that triggers layout when a paint-only property will do.

### 13.3 Enforcement

| Check | Blocks |
| --- | --- |
| No hard-coded Duration outside QMotion | Merge |
| No Curves.* outside QEasing | Merge |
| No Curves.elasticOut, bounceOut, easeOutBack anywhere | Merge |
| No Offset(1.0, 0) literal in a transition | Merge |
| Every AnimationController is disposed | Lint |
| Every route declares an explicit transition | Merge |
| Timeline trace of the 8 primary transitions on a 4GB device | Release |

---

## 14. Motion inventory

| # | Animation | Duration | Easing | Reduced |
| --- | --- | --- | --- | --- |
| 1 | Branch switch | 350 | standard | Fade 150 |
| 2 | Push to child | 350 | standard | Fade 150 |
| 3 | Reader entry | 350 | decelerate | Fade 150 |
| 4 | Mushaf page turn (always RTL) | 350 | standard | Cross-fade |
| 5 | Hero: mini to full player | 350 | standard | Disabled |
| 6 | Hero: surah tile to header | 350 | standard | Disabled |
| 7 | Skeleton shimmer | 1400 loop | standard | Static |
| 8 | Progress value change | 400 | standard | Retained |
| 9 | Button ripple | 50 | - | Retained |
| 10 | Button label to spinner | 150 | standard | Fade 150 |
| 11 | Icon FILL morph | 150 | standard | Instant |
| 12 | Card insert / remove | 250 / 200 | dec / acc | Fade only |
| 13 | Expand tafsir | 250 | standard | Instant |
| 14 | Ayah playback tint | 200 | standard | Retained |
| 15 | Highlight wipe | 250 | standard | Fade |
| 16 | List filter cross-fade | 200 | standard | Retained |
| 17 | Swipe dismiss | 1:1 then 200 | acc | Retained |
| 18 | Dialog in / out | 250 / 200 | dec / acc | Fade only |
| 19 | Sheet in / out | 350 / 250 | dec / acc | Fade only |
| 20 | Sheet content swap | 200 + 250 | standard | Instant |
| 21 | Snackbar in / out | 250 / 200 | dec / acc | Fade |
| 22 | Pull to refresh | 400 min | decelerate | Retained |
| 23 | Splash handoff | 200 | linear | Retained |
| 24 | Tasbih count change | 120 | standard | Instant |
| 25 | Mastery ring | 400 | standard | Instant |
| 26 | Nav indicator morph | 250 | standard | Instant |
| 27 | Segmented indicator slide | 250 | standard | Cross-fade |
| 28 | Switch thumb | 150 | standard | Instant |

Twenty-eight animations in the entire product. That number is a deliberate ceiling, not an accident - every addition requires justifying which spatial relationship it clarifies.

---

## 15. Four positions worth arguing about

**1. No entry stagger will be the most contested decision here.** It is the animation that makes demos look expensive. It also taxes every subsequent visit to a screen users visit hundreds of times.

**2. No animated splash will read as unpolished to whoever owns brand.** A logo animation is the app spending the user time on itself at the exact moment they are most impatient.

**3. No press-scale on buttons will feel less premium in side-by-side comparison.** It costs a layout pass per tap, and with four live navigator branches those passes show up in the frame graph on a Galaxy A14. This one is worth revisiting if profiling disagrees.

**4. Suspending all motion during recitation playback goes further than any accessibility guideline requires.** No standard demands it. But a user following the recitation of the Quran word by word should have exactly one thing moving on screen, and that thing should be the highlight tracking the audio.
