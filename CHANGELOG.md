# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.0] - Statistics & Database
### Added
- **Drift/SQLite database:** Integrated Drift ORM with platform-specific connections (native SQLite on Android/Windows, IndexedDB with WASM fallback on Web).
- **Session logging:** Timer automatically records completed focus, short break, and long break sessions to the local database.
- **Statistics dashboard:** Built an interactive statistics screen with summary cards (total sessions, total focus time, daily average, current streak).
- **Focus bar chart:** Added daily focus-minutes bar chart powered by fl_chart with date-range-aware queries.
- **Date range selector:** Added a date range picker (Today, 7 Days, 30 Days, All Time, Custom) that drives statistics filtering.
- **CSV export:** Added one-tap CSV export of session data via the file_saver package, encoded as UTF-8.
- **Clear stats & refresh buttons:** Added toolbar actions to clear all session data and manually refresh statistics.
- **Web notification permissions:** Prompt for notification permissions on first user interaction in web builds.
- **Testing preset:** Added a hidden custom testing preset in debug builds for rapid session-cycle QA.

### Changed
- **Timer cycle text logic:** Corrected the session/cycle display label to accurately reflect the current position in the Pomodoro cycle.
- **Ambient track restart:** Prevented unnecessary ambient track restarts when the same track is already playing.

### Fixed
- **Timer infinite loop:** Resolved a 0-second remaining edge case that caused the timer to loop indefinitely.
- **Phase alarm logic:** Corrected alarm trigger conditions during phase transitions and added error handling for session logging.
- **Stats auto-dispose:** Prevented premature disposal of date range and statistics providers when navigating between tabs.
- **Stats refresh blocking timer:** Fixed an issue where refreshing statistics could pause or stop the active timer.
- **CSV encoding:** Switched CSV export encoding from UTF-16 to UTF-8 for broader compatibility.
- **Web audio double prefix:** Resolved a bug causing doubled `assets/` path prefixes in web audio asset loading.
- **Web WASM loading:** Fixed base href resolution and bootstrap entry for WASM builds; added IndexedDB fallback when WASM SQLite fails.
- **Web WASM notifications:** Resolved missing notification support in WASM-compiled web builds.
- **Web asset 404s:** Bypassed download manager interference by loading audio assets via rootBundle instead of HTTP URLs.
- **Drift web import:** Removed unused drift web import that broke native database connections.
- **Android notification flickering:** Resolved rapid notification re-posting and added push grouping.
- **Android lockscreen visibility:** Ensured notification visibility on Samsung lockscreens.
- **Notification deduplication:** Corrected the logic that suppressed rapid duplicate phase notifications; removed stale ID tracking in favor of normalised-body comparison.
- **Foreground service importance:** Reduced notification channel importance to low and throttled update frequency.
- **SystemChrome platform guard:** Added a platform check to prevent SystemChrome calls on unsupported platforms (web).
- **Settings theme mode RangeError:** Added bounds check for theme mode index loaded from shared preferences.
- **Testing preset visibility:** Ensured the testing preset is hidden in release builds.
- **Unreachable web fallback:** Removed dead-code conditional import path for web notifications.
- **Web notification JS interop:** Explicitly cast `web.Notification.permission` to a Dart string (`.toString()`) to fix unreliable permission checks under WASM.
- **Custom date range end-date:** Normalised the custom Date Range picker end-date to encapsulate the full 23:59:59.999999 window so queries include the entire last day.
- **Session label during break:** Corrected the session counter displayed during break phases to show the accurate completed-cycle count instead of a fallback expression.

### Performance
- **Timer rebuild reduction:** Added equality operator overrides to `TimerState` to prevent unnecessary widget rebuilds on identical state emissions.
- **Foreground service overhead:** Throttled timer-to-foreground-service update calls and reduced notification channel importance.
- **Focus bar chart All Time freeze:** Capped the `focusByDay` iteration to a maximum of 100 days to prevent UI freezing loops on the 'All Time' preset.

### Docs & Tooling
- Regenerated Riverpod provider outputs.
- Added drift web worker build artifacts to `.gitignore`.

## [0.4.0] - Audio & Notifications
### Added
- **Audio service architecture:** Added shared audio service abstractions with platform-specific implementations for mobile/desktop and web.
- **Foreground/background runtime support:** Added foreground service integration for Android timer continuity and action callbacks.
- **Notification service layer:** Added cross-platform notification service wiring with web and Windows-specific helper paths.
- **Ambient track controls:** Added independent Focus, Break, and Alarm audio toggles and phase-based ambient track selection in settings.
- **Audio asset set:** Added runtime alarm and ambient tracks in OGG format (with temporary MP3 legacy copies retained).
- **Web looping backend:** Implemented Web Audio API path for seamless ambient looping in browsers.

### Changed
- **Timer behavior integration:** Connected timer phase transitions to alarm playback, ambient transitions, and notification preferences.
- **Windows playback backend:** Switched Windows playback handling to media_kit-backed runtime path.
- **UI controls placement:** Moved timer audio controls to sit below the phase chip for better cross-platform header consistency.

### Fixed
- **Web runtime fallbacks:** Hardened web asset manifest/path loading and browser notification fallbacks.
- **Ambient stability:** Prevented unintended ambient restart on alarm mute and improved fade/transition reliability.
- **Notification noise:** Suppressed rapid duplicate phase notifications.
- **Android release playback:** Added media3/proguard keep fixes and corrected audio usage enums.
- **Windows startup reliability:** Replaced problematic notification plugin path and fixed plugin DLL staging beside runner executable.
- **Android back callback:** Enabled `OnBackInvokedCallback` support in manifest.

### Performance
- **Android service load:** Reduced background timer/service overhead during active sessions.

### Docs & Tooling
- Added local PowerShell troubleshooting guidance for Android workflows.
- Refreshed generated provider/mocks and dependency lockfile during integration work.

## [0.3.0] - Settings & Customization
### Added
- **Timer Presets:** Added the ability to choose between Classic (25/5/15), Extended (50/10/30), or Custom presets.
- **Custom Durations:** Added interactive sliders to freely customize Focus, Short Break, and Long Break durations.
- **Auto-Start Automation:** Added settings toggles to automatically start breaks after a focus session, or automatically start the next pomodoro after a break ends.
- **Keep Screen On:** Integrated `wakelock_plus` to provide a toggle that prevents the device screen from going to sleep while the timer is running.
- **Theme Selector:** Added a dropdown to manually override the system theme and force Light or Dark mode.
- **Persistence:** Integrated `SharedPreferencesAsync` to remember all user settings across app restarts.
- **Version Display:** Added the current application version string to the bottom of the Settings screen.

### Fixed
- **Timer Reset Bug:** Fixed an issue where stopping or resetting a custom timer would incorrectly revert the focus duration back to the 25-minute default instead of the user's custom preference.
- **Session Counting Logic:** Fixed an issue where the session counter UI incremented prematurely during a short break. It now correctly increments only upon returning to the next active Focus phase.
- **Long Break Transitions:** Corrected the cycle logic to accurately transition to a Long Break *after* the 4th full focus phase completes, adhering strictly to the standard Pomodoro Technique.

## [0.2.0] - Core Timer Engine
### Added
- **Core Timer Logic:** Implemented the `TimerNotifier` powered by Riverpod to handle countdowns using a background-safe `DateTime` target approach.
- **Phase Transitions:** Added automatic and manual transitions between Focus, Short Break, and Long Break phases.
- **Controls:** Added Play, Pause, Reset, and Skip functionality to the Timer screen.
- **Cycle Tracking:** Implemented initial logic to track completed pomodoros to trigger a long break after 4 sessions.
- **UI:** Built the `TimerDisplay` circular progress indicator and formatted time text.

## [0.1.0] - Project Foundation
### Added
- **Initial Setup:** Scaffolded the Flutter application targeting Android, Windows, and Web platforms.
- **Architecture:** Established a feature-first folder structure and integrated Riverpod for state management.
- **Navigation:** Implemented `go_router` with a persistent `ShellRoute` and bottom `NavigationBar`.
- **Theming:** Configured Material 3 themes (Light/Dark) utilizing the `google_fonts` package (Poppins) and a custom Pomodoro-red seed color.
