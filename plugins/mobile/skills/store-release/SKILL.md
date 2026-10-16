---
name: store-release
description: Prepare and ship an Expo / React Native release to TestFlight and the App Store first, then Google Play — version bumps, quality gates, iOS and Android compliance (privacy manifest, usage strings, encryption export, account deletion, Data safety, target SDK), EAS Build and Submit, store listing, phased/staged rollout, and OTA update rules. Use for internal/TestFlight builds and production releases, or when asked "how do I release", "ship to the App Store", "submit to Play".
---

# Store release (iOS first, then Android)

Follow the project's own release doc if it has one. Otherwise this checklist. Confirm with the user before running
any `eas build`/`eas submit` command — they cost build minutes and publish to real users.

## 1. Decide: store build or OTA update?
- **EAS Update (OTA)** only for JS/asset changes that keep the same native runtime (`runtimeVersion` policy unchanged).
  Never use OTA to ship changes the store reviewer should see (new features that change the app's purpose) or anything
  that needs new native code/permissions.
- Native code, Expo SDK upgrade, new native dependency, new permission, app config change → **store build**.

## 2. Version
- Bump the user-facing `version` (semver) in app config. Build numbers (`ios.buildNumber`, `android.versionCode`) via
  `"autoIncrement": true` with `appVersionSource: "remote"` in `eas.json` (or the repo's existing approach).
- Update the CHANGELOG / release notes (user-facing "What's New" text, plain language).

## 3. Quality gates
- `verify` skill green (lint, typecheck, tests). `npx expo-doctor` clean. `npx expo install --check` aligned.
- `perf-audit` skill for releases with UI changes; `review-changes` on the release diff.
- Manual smoke test on **release builds**, iOS device first, then a low/mid-range Android device: sign up / log in,
  core flow end to end, offline → online, background/foreground, push notification, deep link, logout wipes data,
  largest text + VoiceOver spot check, dark mode.
- Crash/analytics SDK sourcemaps upload configured (Sentry/EAS) so production crashes are readable.

## 4. iOS / App Store compliance
- **Privacy manifest** (`PrivacyInfo.xcprivacy` via `ios.privacyManifests` in app config): required-reason APIs
  declared (UserDefaults, file timestamps, disk space, boot time) — including those used by dependencies.
- **Usage strings** (`ios.infoPlist`) for every permission requested (camera, photos, location, Face ID, contacts,
  microphone, tracking) — specific and honest, or review rejects.
- **Encryption export**: `ITSAppUsesNonExemptEncryption` set (`false` if only standard HTTPS/OS crypto; otherwise answer
  the export compliance questions).
- **Account deletion in-app** if the app supports account creation (Guideline 5.1.1(v)).
- **Sign in with Apple** if any third-party social login is offered (Guideline 4.8).
- In-app purchases for digital goods (no external payment links unless entitled); App Tracking Transparency prompt if
  tracking; privacy nutrition labels match what the app actually collects; demo account + notes for the reviewer.
- Screenshots: 6.9" iPhone (required) and 13" iPad if `supportsTablet`; app preview optional.

## 5. Android / Google Play compliance
- **Target SDK** meets Play's current requirement (check the Expo SDK's default); 16 KB page size support for native libs.
- **Data safety** form matches actual collection/sharing; privacy policy URL live; account deletion link (web) if accounts exist.
- Permissions minimal; sensitive permissions (location in background, SMS, accessibility) need declarations.
- Signing: Play App Signing with the upload key managed by EAS credentials.
- Listing: phone screenshots + 7"/10" tablet if supported, feature graphic, short/full description, content rating.

## 6. Build and submit (confirm first)
```bash
eas build --profile production --platform ios        # iOS first
eas submit --platform ios --latest                   # → TestFlight
eas build --profile production --platform android
eas submit --platform android --latest               # → internal track first
```
- TestFlight internal testers → external group if needed. Play: internal → closed → production.

## 7. Roll out and monitor
- iOS: **phased release** (7-day). Android: **staged rollout** (e.g. 10% → 50% → 100%).
- Watch crash-free sessions/users, ANRs (Android), and reviews for 24–48 h before widening. Halt the rollout on a spike.
- Keep the server backwards compatible with the previous app version — users don't all update.

## 8. Record
Log version, build numbers, date, platforms, rollout status and notable issues in the project's tracker/CHANGELOG.
