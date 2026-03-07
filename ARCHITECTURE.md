# Pomer — Architecture Guide

> This document is intended as **context for LLM-assisted development**. Paste it into prompts to maintain architectural consistency across sessions.

---

## Overview

**Pomer** is a Pomodoro timer app built with Flutter and Dart. It targets:

| Platform | Priority |
|----------|----------|
| Android  | Primary  |
| Windows  | Secondary |
| Web      | Tertiary |

No iOS, macOS, or Linux support is planned for v1.x.

---

## Architecture Pattern

Pomer uses a **feature-first** folder structure combined with **Riverpod** for state management.

### Why feature-first?

Each feature (`timer`, `settings`, `statistics`, `tasks`, `gamification`) is a self-contained vertical slice with its own:
- `models/` — Plain Dart data classes (no Flutter dependencies)
- `providers/` — Riverpod providers and business logic
- `widgets/` — Reusable, feature-specific UI components
- `screens/` — Full-page route targets

This keeps feature code isolated, making it easy to add, remove, or refactor features without cross-cutting concerns.

---

## Folder Structure

```
lib/
├── main.dart                   # App entry point (ProviderScope + runApp)
├── app.dart                    # App widget, GoRouter config, AppShell
├── core/
│   ├── constants/
│   │   └── app_constants.dart  # App-wide constants (name, version, durations)
│   ├── theme/
│   │   └── app_theme.dart      # Material 3 light/dark themes, Google Fonts
│   ├── utils/
│   │   └── platform_utils.dart # Static platform detection helpers
│   └── services/               # Shared services (e.g., audio, notifications)
├── features/
│   ├── timer/                  # Pomodoro timer feature (v0.2.0)
│   ├── settings/               # User preferences feature (v0.3.0)
│   ├── statistics/             # Session stats & database feature (v0.5.0)
│   ├── tasks/                  # Task tracking feature (v0.6.0)
│   └── gamification/           # Plant rewards & streaks feature (v0.7.0)
└── database/                   # Drift database definitions (v0.5.0+)
```

---

## State Management — Riverpod

Pomer uses [Riverpod](https://riverpod.dev) (v2.x) for all state management.

### Conventions

- **Code generation** (`riverpod_annotation` + `riverpod_generator`) is preferred for new providers once features are implemented. Run `dart run build_runner build` to generate `.g.dart` files.
- **`StateProvider`** is acceptable for simple, global UI state (e.g., `themeModeProvider`).
- Providers live in `features/<feature>/providers/` or `core/` for shared state.
- Always use `ref.watch` in `build` methods and `ref.read` in callbacks.
- Prefer `AsyncNotifierProvider` for async data (database, network).

### Example provider structure (future feature)

```dart
// features/timer/providers/timer_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'timer_provider.g.dart';

@riverpod
class TimerNotifier extends _$TimerNotifier {
  @override
  TimerState build() => const TimerState.initial();
  // ...
}
```

---

## Navigation — GoRouter

Navigation uses [GoRouter](https://pub.dev/packages/go_router) with a `ShellRoute` that provides the persistent `NavigationBar`.

### Route table

| Path        | Screen             | Nav Index |
|-------------|--------------------|-----------|
| `/`         | `TimerScreen`      | 0         |
| `/stats`    | `StatisticsScreen` | 1         |
| `/settings` | `SettingsScreen`   | 2         |

### Deep linking

GoRouter enables declarative deep linking on all platforms. Future features should add sub-routes under the existing top-level routes (e.g., `/stats/detail`).

---

## Theming — Material 3

- `AppTheme.lightTheme` and `AppTheme.darkTheme` are defined in `core/theme/app_theme.dart`.
- Seed color: `Color(0xFFE53935)` (tomato red — Pomodoro-inspired).
- Typography: **Poppins** via `google_fonts`.
- `ThemeMode` is controlled by `themeModeProvider` (`StateProvider<ThemeMode>`), defaulting to `ThemeMode.system`.

---

## Data Layer

### v0.1.0–v0.2.0
No persistent data. Timer state is in-memory only. Theme mode defaults to system.

### v0.3.0
- **SharedPreferences** for simple key-value settings (durations, theme preference, auto-start toggle).
- Package: `shared_preferences: ^2.x`

### v0.5.0 (current)
- **Drift** (SQLite) for structured local data (session history, tasks, achievements).
- Database definitions in `lib/database/`.
- Platform-specific connections: native SQLite on Android/Windows, IndexedDB with WASM fallback on Web.
- Each feature accesses the database through its own Drift DAO.
- CSV export support for session data (UTF-8 encoded).

---

## Coding Conventions

1. **`const` constructors everywhere** — Use `const` on all widget constructors and immutable values. Enforced by `prefer_const_constructors` lint.
2. **Trailing commas** — All multi-line function calls and declarations must have a trailing comma. Enforced by `require_trailing_commas` lint.
3. **`final` locals** — All local variables that are not reassigned must be `final`. Enforced by `prefer_final_locals` lint.
4. **No `print()`** — Use a proper logging solution. Enforced by `avoid_print` lint.
5. **Single quotes** — Use single quotes for Dart strings. Enforced by `prefer_single_quotes` lint.
6. **Feature isolation** — Features must not import from other features. Cross-feature communication goes through shared providers in `core/`.
7. **`super.key`** — Use `super.key` parameter syntax in widget constructors (Dart 3+).
8. **Screen naming** — All route screens are named `<Feature>Screen` and live in `features/<feature>/screens/`.
9. **Audio format** — Use `.ogg` for runtime audio playback. `.mp3` is deprecated and scheduled for removal.

### Audio Format Rationale

- MP3 introduces encoder padding and frame-boundary artifacts that are unsuitable for seamless ambient loops.
- OGG gives more consistent looping behavior in our playback pipeline and improves transition quality.
- Limiting runtime audio to one format reduces maintenance overhead and prevents mixed-format regressions.

---

## Platform-Specific Notes

### Android
- Min SDK: 21 (Android 5.0 Lollipop)
- Target SDK: 34 (Android 14)
- Application ID: `com.petersdigital.pomer`
- Main activity: `com.petersdigital.pomer.MainActivity` (extends `FlutterActivity`)

### Windows
- Built with CMake + MSVC
- Window title: "Pomer"
- Initial size: 1280×720

### Web
- PWA-capable (`manifest.json` + service worker)
- Theme color: `#E53935`

---

## CI/CD

Workflows are split by intent:

1. **`ci.yml`** (push/PR to `main`)
  - `analyze-and-test` on push + PR to `main`
  - Debug build matrix (Android/Web/Windows) on push to `main`

2. **`dev.yml`** (push to non-`main` branches)
  - Runs analyze + tests
  - Builds split Android release APK and pushes it to Telegram for rapid dev feedback

3. **`release.yml`** (SemVer tag push: `vMAJOR.MINOR.PATCH`)
  - Verifies the tagged commit belongs to `main`
  - Runs analyze + tests
  - Builds release artifacts: Android APK, Web, Web WASM, Windows
  - Publishes GitHub Release assets
  - Deploys web output to GitHub Pages (`https://petersdigital.github.io/pomer/`)

Release notes are generated from the matching section in `CHANGELOG.md` for the pushed tag version.

---

## Version Roadmap

| Version | Milestone |
|---------|-----------|
| v0.1.0 ✅ | Project Foundation — Flutter setup, navigation shell, theming |
| v0.2.0 ✅ | Core Timer Engine — Timer countdown, phase transitions, play/pause/reset/skip, cycle tracking |
| v0.3.0 ✅ | Settings & Customization — Custom durations, presets, auto-start, theme selector, keep screen on |
| v0.4.0 ✅ | Audio & Notifications — Alarm sounds, ambient audio, Android foreground service, notifications |
| v0.5.0 ✅ | Statistics & Database — Drift/SQLite, session logging, dashboards, charts, CSV export |
| v0.6.0 | Task Tracking — Task binding, task list, tags, task-filtered statistics |
| v0.7.0 | Gamification — Plant rewards, garden collection, streaks, unlock progression |
| v0.8.0 | Platform Hardening — App icons, splash screen, PWA, responsive layout, accessibility |
| v0.9.0 | Polish & Bug Bash — Animations, onboarding, edge cases, integration tests, final polish |
| v1.0.0-RC | Release Candidate — Version bump, changelog, release artifacts, beta testing |