# <Project name> (React Native / Expo)

Context for Claude Code sessions on this repository. Read this first, then the rule or doc for what you're touching.
Team workflow, agents and skills: `.claude/rules/workflow.md`. Stack rules: `.claude/rules/react-native.md`.
**Quality bar (iOS first 60/40, accessibility, performance, offline, dark mode): `.claude/rules/mobile-quality.md`.**

## What this is
<2–4 sentences: what the app does, who uses it (age, tech comfort, accessibility needs), and what makes it unusual
(offline-first? sensitive data? real-time? payments?).>

## Platform priority
**iOS first, Android second — 60 / 40.** Design, build and verify on iOS first; Android ships working and polished.
Minimum OS: iOS <version> · Android <API level>. Target devices for performance: <oldest iPhone> · <low-end Android>.

## Stack
- Expo SDK <version> · New Architecture · Hermes · TypeScript strict · expo-router
- TanStack Query (server state) · Zustand (client state) · react-hook-form + Zod
- Reanimated + Gesture Handler · FlashList · expo-image · expo-secure-store · <local DB: expo-sqlite + Drizzle / MMKV>
- Backend: <API repo/path and base URL per environment>  ·  Auth: <approach>
- Testing: Jest (`jest-expo`) + React Native Testing Library · <Maestro E2E>

## Where things are
| Path | What |
|---|---|
| `src/app/` | expo-router routes only — `(auth)/`, `(app)/`, `(tabs)/` |
| `src/features/<feature>/` | screens, components, hooks, `api.ts`, `store.ts`, `__tests__/` |
| `src/ui/` | design system — theme tokens (light + dark) and primitives |
| `src/lib/` | API client, storage, utilities |
| `<docs path>` | product decisions, roadmap/tracker |

## Commands
```bash
npx expo start                 # dev server (dev client)
npx expo run:ios               # build + run on iOS simulator (primary)
npx expo run:android           # build + run on Android emulator
<pm> run check                 # tsc + eslint + prettier + jest
npx expo install --check       # SDK version alignment after dependency changes
npx expo-doctor                # before releases
eas build --profile <p> --platform ios|android    # confirm with the owner first
```

## Invariants
1. <e.g. Tokens and keys live only in expo-secure-store — never in state, MMKV, logs or route params.>
2. <e.g. Writes go to the local DB first and sync later; the UI never blocks on the network.>
3. <e.g. Never break an API field that a released app version uses.>
<Replace with the real ones.>

## Conventions specific to this repo
- <Design direction / design system decisions.>
- <Anything that differs from the rules.>
- Commit format: <match history>.

## Before you finish any task
`<pm> run check`, then run it on the **iOS simulator** (light/dark, largest text, VoiceOver, airplane mode), then
**Android** (back, edge-to-edge, TalkBack). New native dependency → say a dev-client rebuild is needed.

## What NOT to do
- Never use `ScrollView`/`FlatList` for long lists (FlashList); never animate with `setState` per frame (Reanimated).
- Never hard-code colours (theme tokens, light + dark).
- Never ship a screen without loading / empty / error / offline states.
- <Project-specific don'ts.>
