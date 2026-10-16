---
name: perf-audit
description: Measure and audit a React Native / Expo app's performance on real older devices, iPhone first then low/mid-range Android — cold start, list scrolling, re-renders, JS-thread stalls, animation frame rate, memory, bundle and binary size, heavy dependencies — against a performance budget, and produce prioritised fixes. Use before a release, after adding a dependency, or when the app feels slow or janky.
---

# Performance audit (mobile)

Measurement first, then fixes. Never judge performance on a **dev build** — it is several times slower.

## 0. Budget
Use the project's budget (`.claude/rules/*` / docs). If none, use and record this default:

| Metric | Budget |
|---|---|
| Cold start → interactive (release) | iPhone ≤ 2.0 s · low-end Android ≤ 2.5 s |
| Long list scroll (500–1,000 items) | 60 fps on mid devices; no blank cells on low-end |
| Screen transition | native-stack animation, no dropped frames |
| Interaction response (tap → feedback) | < 100 ms |
| JS bundle (Hermes bytecode) | tracked per release; investigate > +10% |
| Memory | stable after navigating back and forth 10× (no growth) |

## 1. Build release variants
```bash
npx expo run:ios --configuration Release --device      # real iPhone if possible (older = better)
npx expo run:android --variant release --device
```

## 2. Measure
1. **Startup** — time from tap to first interactive screen (screen recording at 60 fps, or Xcode Instruments "App
   Launch"; Android `adb shell am start -W` for TotalTime). Note what runs before first render.
2. **Lists** — scroll the longest lists fast; watch for blank cells and frame drops (Perf Monitor: JS and UI fps).
3. **Re-renders** — React DevTools Profiler on the heaviest screens; record a typical interaction; list components
   that re-render without prop changes.
4. **Animations/gestures** — Perf Monitor UI fps during transitions, sheets, swipe actions.
5. **Memory** — Xcode Instruments Allocations/Leaks; Android Studio Memory Profiler; navigate in and out repeatedly.
6. **Bundle** — `npx expo export --platform ios --dump-sourcemap` then `npx source-map-explorer` on the bundle;
   largest modules and anything unexpected. Compare with the last recorded size.
7. **Dependencies** — native modules added since the last audit; question each (size, New Architecture support,
   still needed?).

## 3. Diagnose and fix (highest user impact first)
Use the `rn-performance-reviewer` agent on the hot screens. Typical fixes: defer non-critical startup work until after
first frame; lazy-load heavy screens; FlashList + memoised rows; Zustand selectors / split contexts; move animations to
Reanimated; `expo-image` with correctly sized sources; replace heavy libraries; move heavy computation off the JS thread
or to the server.

## 4. Re-measure and record
Re-run the same measurements after fixes on the same devices. Record results vs budget (before → after) in the
project's tracker/docs, and create tasks for anything still over budget.

```
## Perf audit — <date>, <app version>, devices: <iPhone model / iOS>, <Android model / version>
| Metric | Budget | Before | After | Status |
Top issues fixed: ...
Still over budget: ... → tasks created
```
