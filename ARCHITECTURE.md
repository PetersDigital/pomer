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
│   ├── statistics/             # Session stats feature (v0.5.0)
│   ├── tasks/                  # Task list feature (v0.4.0)
│   └── gamification/           # Achievements/streaks feature (v0.6.0)
└── database/                   # Drift database definitions (v0.3.0+)
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

### v0.1.0 (current)
No persistent data. Theme mode defaults to system.

### v0.3.0+ (planned)
- **SharedPreferences** for simple key-value settings (durations, theme preference).
- Package: `shared_preferences: ^2.x`

### v0.4.0+ (planned)
- **Drift** for structured local data (sessions, tasks, achievements).
- Database definitions in `lib/database/`.
- Each feature accesses the database through its own Drift DAO.

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

---

## Platform-Specific Notes

### Android
- Min SDK: 21 (Android 5.0)
- Target SDK: 34
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

See `.github/workflows/ci.yml`. On every push to `main` and every PR:

1. **analyze-and-test** — `flutter analyze --fatal-infos` + `flutter test`
2. **build-android** — `flutter build apk --debug` (needs Java 17)
3. **build-web** — `flutter build web`
4. **build-windows** — `flutter build windows` (runs on `windows-latest`)

Build jobs only run if `analyze-and-test` passes.

---

## Version Roadmap

| Version | Milestone |
|---------|-----------|
| v0.1.0  | Project foundation (this PR) |
| v0.2.0  | Pomodoro timer (countdown, sessions) |
| v0.3.0  | Settings (persist durations, theme) |
| v0.4.0  | Task list |
| v0.5.0  | Statistics (session history charts) |
| v0.6.0  | Gamification (streaks, achievements) |
| v0.9.0  | Screenshots, store listing |
| v1.0.0  | Production release |
