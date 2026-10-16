---
name: new-screen
description: Create a new screen, modal, tab or flow in a React Native / Expo (expo-router) app the iOS-first way — thin route file, feature-folder screen component, design-system primitives, TanStack Query/Zustand data, loading/empty/error/offline states, dark mode, VoiceOver and Dynamic Type, FlashList performance, Android adaptation, and a screen test. Use whenever adding or substantially rebuilding a mobile screen. Invoke with /new-screen <screen-name>.
---

# New mobile screen (iOS first, 60 / 40)

**Screen:** $ARGUMENTS

If the project has its own `new-screen` skill, use that instead. Otherwise follow this, adapting paths to the repo's
existing layout (find the closest existing screen and mirror it).

## 1. Decide the route and navigation

- expo-router file under `app/` (or `src/app/`): group by auth state (`(auth)/`, `(app)/`), tabs in `(tabs)/`,
  modals via `presentation: 'modal'` / `'formSheet'` in the layout. Dynamic segments `[id].tsx`.
- **Route files stay thin**: they read params and render a screen component from `features/<feature>/` (or the repo's
  equivalent). No business logic, tests or helpers inside `app/`.
- iOS behaviour first: native-stack push with the large title where the app uses it; swipe-back works; sheets use
  native detents; header buttons follow HIG placement (primary action top-right, Cancel top-left in modals).
  Android: hardware back closes modals/sheets and returns sensibly; edge-to-edge insets; ripple feedback.
- Never pass secrets or large objects through route params — pass ids and load data.

## 2. Build the UI from the design system

- Use the project's primitives (`Screen`, `Text`, `Button`, `Input`, `ListItem`…) and theme tokens — no hard-coded
  colours, sizes or fonts. No design system yet? Create the minimum primitives in `ui/` rather than inline styles.
- Layout: `SafeAreaView`/insets, `KeyboardAvoidingView` (or `react-native-keyboard-controller` if installed) for forms,
  `StyleSheet.create` (or the repo's styling approach — NativeWind/Unistyles), no inline style objects in lists.
- iOS details: haptics on meaningful actions (`expo-haptics`, light impact for toggles/success), SF-style iconography
  if the app uses it, system font weights, context menus/swipe actions where iOS users expect them (always with a
  visible alternative).

## 3. Data and state

- Server data: a TanStack Query hook in `features/<feature>/api.ts` (or `queries.ts`) with a stable key factory;
  mutations invalidate/update the right keys; optimistic updates for quick actions with rollback on error.
- Local/offline data: the repo's local DB (expo-sqlite/Drizzle/WatermelonDB) or persisted query cache.
- Small UI state: Zustand with selectors (never select the whole store). Form state: react-hook-form + Zod schema
  shared with the API contract where possible.

## 4. The four non-negotiables

1. **States** — design all of them as part of the screen, not afterwards:
   loading (skeleton matching the layout, not a bare spinner), **empty** (explains and offers the next action),
   **error** (plain language + retry), **offline** (cached data shown with a subtle offline indicator; writes queued
   or clearly blocked with a message — never fail silently), success feedback.
   Use `@react-native-community/netinfo` / the app's network hook; TanStack Query `onlineManager` wired up.
2. **Accessibility** — roles + labels on every touchable (icon-only buttons especially), headers marked, grouped rows,
   focus order, announcements for async results, Dynamic Type up to the largest sizes without clipping, ≥44pt
   targets, contrast AA in both themes, Reduce Motion respected. (`mobile-accessibility-reviewer` checks this.)
3. **Performance** — FlashList for any list that can grow, memoised rows, no inline closures/objects in `renderItem`,
   `expo-image` for remote images, animations with Reanimated on the UI thread, heavy work deferred until after the
   transition. (`rn-performance-reviewer` checks this.)
4. **Dark mode** — every colour from theme tokens; test both themes, including images/illustrations and status bar style.

## 5. Security
Sensitive screens: screenshot/app-switcher protection where warranted, no sensitive data in logs or params, secure
text entry for secrets. (`mobile-security-reviewer` for auth/storage changes.)

## 6. Test
React Native Testing Library test next to the screen component: renders loading → data, the main interaction, the
empty and error states, and queries by role/label (doubles as an accessibility check). Mock the network at the
boundary the repo already uses.

## 7. Verify (iOS first)
1. `verify` skill (lint → typecheck → tests).
2. Run on the **iOS simulator**: light + dark, largest Dynamic Type, VoiceOver quick pass (swipe through every
   element), airplane mode for the offline state.
3. Then the **Android emulator**: back button, edge-to-edge, TalkBack quick pass, font scale.
4. New native dependency added? Say a dev-client rebuild is required (`npx expo run:ios` / EAS dev build).

## Report
Route + files created · states implemented · iOS checks done · Android checks done · anything not verified.
