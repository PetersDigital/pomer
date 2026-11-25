# Pomer — Implementation Plan & Roadmap Checklist

> Living implementation tracker aligned with [README.md](README.md), [ARCHITECTURE.md](ARCHITECTURE.md), [CHANGELOG.md](CHANGELOG.md), and [AGENTS.md](AGENTS.md).

## Current Status Summary

- **Latest Release (`main`)**: `v0.7.0` (`0.7.0+7`)
- **Active Working Branch**: `main` (next milestone: `v0.8.0`)
- **Supported Platforms**: Android (Primary), Windows (Secondary), Web (Tertiary)
- **Legend**: `[x]` Implemented · `[ ]` Pending

---

## Completed Milestones (`v0.1.0` – `v0.7.0`)

### `v0.1.0` — Project Foundation
- [x] Flutter app scaffold targeting Android, Windows, and Web
- [x] Feature-first directory architecture (`core/`, `features/`, `database/`) with Riverpod v2
- [x] GoRouter navigation shell with persistent bottom `NavigationBar`
- [x] Material 3 light/dark theming with Google Fonts (Poppins) and tomato-red seed color

### `v0.2.0` — Core Timer Engine
- [x] `TimerNotifier` countdown using background-safe target `DateTime` calculation
- [x] Phase transitions across Focus, Short Break, and Long Break (4-cycle default)
- [x] Play, Pause, Reset, and Skip controls with `TimerDisplay` circular progress indicator

### `v0.3.0` — Settings & Customization
- [x] Timer presets: Classic (`25/5/15`), Extended (`50/10/30`), and Custom sliders
- [x] Auto-start Breaks & Auto-start Pomodoros toggles
- [x] Keep Screen On (`wakelock_plus`) and Theme Mode selector (System / Light / Dark)
- [x] Persistent settings via `SharedPreferencesAsync` and app version footer

### `v0.4.0` — Audio & Notifications
- [x] Cross-platform `AudioService` (OGG-only runtime audio pipeline; Web Audio API looping backend; Windows `media_kit` backend)
- [x] Independent Focus, Break, and Alarm audio toggles plus phase track selection
- [x] Android foreground service for timer continuity and action callbacks
- [x] Cross-platform notifications (Android, Windows, Web)

### `v0.5.0` — Statistics & Database
- [x] Drift local database (native SQLite on Android/Windows, IndexedDB with WASM fallback on Web)
- [x] Automatic session logging (`completed`, `skipped`, `interrupted`)
- [x] Statistics dashboard with summary cards, daily focus bar chart (`fl_chart`), and date range filters
- [x] UTF-8 CSV export, Refresh Stats button, and Clear Statistics button with confirmation dialog
- [x] Debug-only Testing preset (`30s / 15s / 1m`) hidden in release builds
- [x] Web audio loading fix via `rootBundle` + `decodeAudioData` (preventing `.ogg` file downloads)
- [x] Android lockscreen notification flicker fix and unique notification IDs for consecutive alerts

### `v0.6.0` — Task Tracking & Battery Optimization
- [x] Task CRUD (`Tasks` table, tags support, completion toggle) and active task binding on timer
- [x] Task- and tag-filtered statistics with CSV task columns
- [x] `BatteryOptimizationService` and `PowerManagementService` (screen-state wake lock management)
- [x] Throttled foreground service updates (every 5s, final 10s every 1s) and `MIN` notification importance
- [x] "Start Fresh" full session reset with confirmation dialog and "Don't ask again" option
- [x] Offline LUFS audio normalization across alarm, ambience, and break tracks
- [x] App branding verified as `Pomer` across Android, Windows, Web, and `app_constants.dart`

---

### `v0.7.0` — Gamification & Timer Performance ✅

#### Core Gamification & Performance
- [x] Drift schema `v3` (`PlantCatalog` & `UserGarden` tables, `v2 -> v3` migration, and idempotent seeding for 4 starter plants plus 5 milestone-unlockable species) in `lib/database/database.dart`
- [x] `GardenRepository` and Riverpod providers (`gardenRepositoryProvider`, `userGardenProvider`, `plantCatalogProvider`)
- [x] Plant reward / withered logging on focus session completion or interruption in `lib/features/timer/providers/timer_provider.dart`
- [x] `/garden` GoRouter route, 5th bottom navigation tab, and initial 3-column emoji `GardenScreen` in `lib/app.dart` and `lib/features/gamification/screens/garden_screen.dart`
- [x] Timer 1Hz rebuild optimization (`ref.watch(...select(...))`) in `TimerScreen` & `TimerControls`
- [x] Foreground task wakeup optimization (`ForegroundTaskEventAction.nothing()`) in `lib/core/services/foreground_service.dart`

#### Architecture & Technical Debt Fixes
- [x] **Enforce feature isolation (`AGENTS.md §2.1`)**: Move shared garden repository/provider (`gardenRepositoryProvider`) out of `lib/features/gamification/providers/` into `lib/core/providers/` so `lib/features/timer/providers/timer_provider.dart` only imports from `core/`
- [x] **Harden `GardenScreen`**: Guard against empty `catalog` (avoid `orElse: () => catalog.first` `StateError`), sort garden items newest-first, format timestamps cleanly, and adapt grid column count for wider desktop/web viewports

#### Remaining Gamification Roadmap Scope
- [x] **Daily focus streak tracking**: Compute and display current/best focus streaks in the Garden / gamification view
- [x] **Unlock progression system**: Add progression milestones and unlockable plant species beyond basic duration tiers
- [x] **Plant reward feedback**: Show a snackbar, banner, or dialog when a focus session grows or withers a plant

#### Testing & Release Prep for `v0.7.0`
- [x] Add unit/widget/DB tests covering:
  - Drift `v2 -> v3` migration and idempotent `PlantCatalog` seeding
  - `GardenRepository` queries/inserts and timer plant reward/wither tier selection
  - Streak calculation & unlock progression providers
  - `GardenScreen` empty, loading, error, populated, and collection states
  - `TimerScreen` plant reward feedback
- [x] Bump version consistently: `pubspec.yaml` (`0.7.0+7`), `lib/core/constants/app_constants.dart` (`'0.7.0'`), and `test/app_constants_test.dart`
- [x] Update docs: add `## [0.7.0]` to `CHANGELOG.md`, mark `v0.7.0 ✅` in `README.md`, and update the 5-tab route table (`/garden`) & `v0.7.0` data layer in `ARCHITECTURE.md`

---

## `v0.8.0` — Platform Hardening, Audio & Timer QoL *(Next Milestone)*

### Audio & Timer QoL
- [ ] **Three independent volume sliders** (Focus Ambient, Break Ambient, Alarm):
  - Persist `focusVolume`, `breakVolume`, and `alarmVolume` (`0.0`–`1.0`, default `1.0`) via `SharedPreferencesAsync` in `AudioPreferencesNotifier`
  - Expose volume sliders in Settings / Audio controls
  - Apply user volume multipliers in both `NativeAudioPlayer` and `WebAudioPlayer` while preserving fade-in/fade-out curves
- [ ] **75% minimum focus completion threshold**:
  - Require at least 75% of planned focus duration (`actualDurationSeconds >= (totalPlannedSeconds * 0.75).round()`) to record a focus session as completed/counted in release builds (retaining the fast threshold for `kDebugMode` / `TimerPreset.testing`)
- [ ] **Custom number of sessions before Long Break**:
  - Make `cyclesBeforeLongBreak` configurable in Settings (default `4`, minimum `1`)
  - Wire the setting through `TimerNotifier` and `TimerDisplay` instead of using a fixed constant
- [ ] **Stop after current session button**:
  - Add an option/toggle on the Timer screen to stop cleanly after the current phase finishes (overriding auto-start for that transition without cancelling the active session)
- [ ] **Clear / Reset Settings button**:
  - Add a Reset Settings action in `SettingsScreen` with a confirmation dialog (supporting resetting timer/app settings and audio preferences cleanly)
- [ ] Add unit/widget tests covering volume sliders, 75% completion threshold, custom cycle count, stop-after-current-session, and reset settings

### Platform Hardening & System Integrations
- [ ] **Upgrade Windows C++20 coroutine plugins**: Upgrade `flutter_local_notifications` and `permission_handler` to major versions using C++20 `<coroutine>` and remove the temporary `_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS` workaround from `windows/CMakeLists.txt`
- [ ] **Resume last active session across app restarts** (Android, Windows & Web):
  - Persist active timer snapshot (phase, status, target timestamp or remaining seconds, completed cycles, active task ID) in local storage/DB
  - Restore or prompt to resume an interrupted/running session on launch
- [ ] **Auto-enable Do Not Disturb (DND) during Focus** (Android):
  - Opt-in toggle in Settings
  - Handle `ACCESS_NOTIFICATION_POLICY` permission request & Android system settings prompt
  - Restore the user's previous interruption filter on pause, reset, break transition, or dispose; no-op gracefully on Windows and Web
- [ ] **App icons & splash screen**: Custom adaptive icons (Android), `.ico` (Windows), PWA/favicon icons (Web), and native splash screen
- [ ] **PWA polish**: Offline caching, service worker update behavior, and installability audit
- [ ] **Responsive layouts**: Adaptive navigation (`NavigationRail` / wide breakpoints) and spacing for Windows desktop and Web
- [ ] **Accessibility audit**: Semantic labels, keyboard shortcuts/focus traversal, color contrast, and text scaling
- [ ] **Screenshots**: Capture and add multi-platform screenshots to `README.md`

---

## `v0.9.0` — Polish, Session Scheduling & Bug Bash

- [ ] **Scheduled / Planned sessions**:
  - Allow starting a planned focus block by choosing a preset and target number of sessions
  - Display remaining sessions in the scheduled block and a completion summary when finished
- [ ] **Animations & micro-interactions**: Smooth timer ring transitions, phase transition feedback, and plant growth/reward animations
- [ ] **Onboarding flow**: First-launch walkthrough covering presets, notifications, and Android battery optimization guidance
- [ ] **Legacy audio cleanup**: Remove deprecated `.mp3` assets per the OGG-only policy once verified unused
- [ ] **Integration tests & cross-platform bug bash**: End-to-end tests and edge-case verification across Android, Windows, and Web

---

## `v1.0.0-RC` — Release Candidate

- [ ] Version bump to `1.0.0` (`pubspec.yaml`, `lib/core/constants/app_constants.dart`, Android `versionName`/`versionCode`)
- [ ] Final `CHANGELOG.md`, `README.md`, and `ARCHITECTURE.md` review and alignment
- [ ] Release builds & smoke verification on Android (release APK), Web, Web WASM, and Windows
- [ ] Beta testing pass and signed SemVer release tag pushed from `main`

---

## Post `v1.0.0` — Future Ideas

> To be synced into the Future Ideas section of [README.md](README.md).

- [ ] **Session Target Configurations**: Daily target number of completed Pomodoro cycles
- [ ] **Live Update Notifications**: Rich ongoing progress notifications (e.g., Android Live Updates)
- [ ] **WearOS Support**: Companion watch timer display and playback controls

---

## Release Gate & Verification Checklist (`AGENTS.md`)

Before merging any milestone to `main` and tagging a release:

- [ ] Mandatory lints pass (`prefer_const_constructors`, `require_trailing_commas`, `avoid_print`, `prefer_single_quotes`, `prefer_final_locals`)
- [ ] Feature isolation verified (no `features/*` file imports another `features/*` file)
- [ ] `flutter analyze --fatal-infos` passes cleanly
- [ ] `flutter test` passes with all tests green
- [ ] Platform builds succeed for impacted targets (`flutter build apk --debug`, `flutter build web`, `flutter build windows`)
- [ ] Version numbers match across `pubspec.yaml`, `lib/core/constants/app_constants.dart`, and Android Gradle config
- [ ] `CHANGELOG.md`, `README.md`, and `ARCHITECTURE.md` are updated and accurate
- [ ] Commits follow Conventional Commits with type and scope (no version numbers in commit subjects)
- [ ] Release commit is on `main` and tagged with a signed tag (`git tag -s vX.Y.Z -m "..."`)
