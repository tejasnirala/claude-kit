---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "app.json"
  - "app.config.*"
  - "eas.json"
  - "package.json"
---

# React Native & Expo

Stack defaults (the repo's choices win): Expo (latest stable SDK, New Architecture, Hermes) · TypeScript strict ·
expo-router · TanStack Query (server state) · Zustand (small client state) · react-hook-form + Zod · Reanimated +
Gesture Handler (motion) · FlashList (lists) · expo-image · expo-secure-store (secrets) · MMKV or SQLite for local data
· Jest (`jest-expo`) + React Native Testing Library · Maestro for E2E if used.

## Expo discipline
- **Expo changes every SDK.** Before using an Expo/EAS/React Native API, check the docs for the SDK version in
  `package.json` — don't rely on memory. The official `expo` plugin's skills cover routing, dev client, EAS and upgrades.
- Install with `npx expo install <pkg>` so versions match the SDK; run `npx expo install --check` after dependency
  changes and `npx expo-doctor` before releases.
- Prefer Expo modules. Every new native dependency needs a reason, New Architecture support, and a note that a
  dev-client rebuild is required (it won't work via reload/OTA).
- Config in `app.config.ts`; secrets never in it (the bundle is public); build-time secrets via EAS.

## Project layout
- `app/` (or `src/app/`): expo-router routes **only** — thin files that render screen components. No tests,
  components or helpers inside it. Groups by state: `(auth)/`, `(app)/`, `(tabs)/`; modals via layout `presentation`.
- `features/<feature>/`: screens, components, hooks, `api.ts` (TanStack Query hooks), `store.ts` (Zustand),
  `types.ts`, `__tests__/`.
- `ui/` (design system): theme tokens (colour, spacing, typography, radii — light + dark) and primitives
  (`Screen`, `Text`, `Button`, `Input`, `ListItem`, `Sheet`). Screens use these, not raw styles.
- `lib/`: API client (auth refresh, base URL, error mapping), storage, utilities.

## Components
Function components with typed props; `StyleSheet.create` (or the repo's styling lib) with tokens — no hard-coded
colours/sizes, no inline style objects in lists; platform files (`*.ios.tsx`/`*.android.tsx`) only when behaviour
truly differs, otherwise `Platform.select` locally.

## Data and state
- All network calls through the shared API client; TanStack Query hooks with a key factory; `onlineManager` +
  `focusManager` wired to NetInfo/AppState; optimistic updates with rollback.
- Zustand with selectors (`useShallow` for multiple fields) — never select the whole store; persist only non-sensitive
  state.
- Sensitive values (tokens, keys) only in `expo-secure-store` — never in state, MMKV/AsyncStorage, logs or route params.

## Navigation
Pass ids in params, never objects or secrets; deep links validate params and never trigger privileged actions without
confirmation; typed routes if the repo enables them.

## Tooling
`tsc --noEmit`, ESLint, Prettier and Jest must pass before committing (often one `check` script). Path alias `@/…`.
