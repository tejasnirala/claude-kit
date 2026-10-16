---
paths:
  - "**/*.tsx"
  - "**/app/**"
  - "**/features/**"
  - "**/ui/**"
  - "**/components/**"
---

# Mobile quality bar — iOS first (60 / 40), and four non-negotiables

## Platform priority: iOS 60 · Android 40
- **iOS sets the bar.** Design, build and verify every feature on the iOS simulator/device first, then Android.
- Follow Apple's Human Interface Guidelines for navigation (native stack, large titles where used, swipe-back), sheets
  (native detents), gestures, haptics (`expo-haptics` on meaningful actions), typography (SF/system font, Dynamic
  Type), safe areas, and placement of actions.
- Android must still feel native and polished — adapt where iOS patterns would feel broken: hardware/gesture back,
  edge-to-edge insets, ripple feedback, permission flows, notification channels, Material date/time pickers.
- When an API/library is iOS-only or behaves differently, ship the complete iOS path plus a **working** Android
  fallback. Never block iOS on Android parity; never ship Android broken.
- Reports and PRs show iOS results first, then Android. Screenshots: iPhone first.

## Non-negotiable 1 — Accessibility
- Every touchable has `accessibilityRole` and an `accessibilityLabel` when its text isn't descriptive (icon-only
  buttons always); state via `accessibilityState`; headers marked; related content grouped; decorative images hidden.
- Works end to end with **VoiceOver** (primary) and TalkBack: logical focus order, modals trap focus, async results
  announced (`AccessibilityInfo.announceForAccessibility`).
- Dynamic Type / font scaling to the largest sizes without clipping (no fixed text-container heights, no
  `allowFontScaling={false}` on content). Touch targets ≥ 44×44 pt (use `hitSlop`).
- Contrast WCAG AA in **both** themes; never colour-only meaning; Reduce Motion respected (`useReducedMotion`).
- Gestures always have a visible alternative; destructive actions confirm (and offer undo where possible); errors in
  plain language.

## Non-negotiable 2 — Performance budget
Judged on **release builds** on older devices (iPhone ~5 years old first; low/mid Android second):

| Metric | Budget |
|---|---|
| Cold start → interactive | iOS ≤ 2.0 s · low-end Android ≤ 2.5 s |
| Long lists | 60 fps, no blank cells — FlashList, memoised rows, no inline closures/objects in `renderItem` |
| Transitions & animations | native-stack transitions; Reanimated worklets on the UI thread; no per-frame `setState` |
| Interaction feedback | < 100 ms (pressed state / haptic immediately) |
| JS bundle | track per release; investigate any +10% |

Also: `expo-image` with right-sized sources; defer non-critical startup work until after first frame; no heavy sync
work on the JS thread during interaction; no unbounded caches. Use the `perf-audit` skill before releases.

## Non-negotiable 3 — Offline-tolerant
- Every data screen handles **loading, empty, error and offline** states — designed, not defaulted.
- Show cached data when offline with a subtle indicator; queue writes for retry (or block them with a clear message)
  — **never fail silently**; reconcile on reconnect (TanStack Query `onlineManager` + NetInfo; local DB for
  offline-first features).
- Network errors, timeouts and slow connections produce plain-language messages with retry.

## Non-negotiable 4 — Dark mode
Every colour comes from theme tokens with light and dark values (`useColorScheme` / the theme provider); status bar,
navigation chrome, images/illustrations and shadows checked in both; test both before calling a screen done.

## Definition of done for a screen
- [ ] iOS simulator: light, dark, largest Dynamic Type, VoiceOver pass, airplane mode.
- [ ] Android emulator: back behaviour, edge-to-edge, TalkBack pass, font scale, dark mode.
- [ ] Loading / empty / error / offline states implemented and seen.
- [ ] FlashList + memoised rows for lists; no jank on a release build of a large list.
- [ ] RNTL test for render + main interaction + states.
