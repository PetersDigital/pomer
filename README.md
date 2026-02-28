# Pomer 🍅

> **A Pomodoro timer app for Android, Windows & Web.** Built with Flutter & Dart.

[![CI](https://github.com/PetersDigital/pomer/actions/workflows/ci.yml/badge.svg)](https://github.com/PetersDigital/pomer/actions/workflows/ci.yml)

---

## About

Pomer is a clean, Material 3 Pomodoro timer app designed to help you stay focused using the [Pomodoro Technique](https://en.wikipedia.org/wiki/Pomodoro_Technique). Work in focused 25-minute intervals, take short breaks, and track your progress — all in a beautiful, distraction-free interface.

---

## Feature Roadmap

| Version | Milestone |
|---------|-----------|
| **v0.1.0** ✅ | Project foundation — Flutter setup, navigation shell, theming |
| **v0.2.0** ✅ | Core Timer Engine — Timer countdown, phase transitions, play/pause/reset/skip, cycle tracking |
| **v0.3.0** ✅ | Settings & Customization — Custom durations, presets, auto-start, theme selector, keep screen on |
| v0.4.0 | Audio & Notifications — Alarm sounds, ambient audio, Android foreground service, notifications |
| v0.5.0 | Statistics & Database — Drift/SQLite, session logging, dashboards, charts, CSV export |
| v0.6.0 | Task Tracking — Task binding, task list, tags, task-filtered statistics |
| v0.7.0 | Gamification — Plant rewards, garden collection, streaks, unlock progression |
| v0.8.0 | Platform Hardening — App icons, splash screen, PWA, responsive layout, accessibility |
| v0.9.0 | Polish & Bug Bash — Animations, onboarding, edge cases, integration tests, final polish |
| v1.0.0-RC | Release Candidate — Version bump, changelog, release artifacts, beta testing |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | [Flutter](https://flutter.dev) (stable channel) |
| Language | Dart ≥ 3.0 |
| State Management | [Riverpod](https://riverpod.dev) v2 |
| Navigation | [GoRouter](https://pub.dev/packages/go_router) |
| Theming | Material 3 + [Google Fonts](https://pub.dev/packages/google_fonts) (Poppins) |
| Local Storage | [SharedPreferences](https://pub.dev/packages/shared_preferences) (v0.3.0+), [Drift](https://pub.dev/packages/drift) (v0.5.0+) |
| Audio | [just_audio](https://pub.dev/packages/just_audio) (v0.4.0+) |
| Notifications | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) (v0.4.0+) |
| Charts | [fl_chart](https://pub.dev/packages/fl_chart) (v0.5.0+) |
| Lint | [flutter_lints](https://pub.dev/packages/flutter_lints) + [riverpod_lint](https://pub.dev/packages/riverpod_lint) |

---

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.x (stable channel)  
  Install via [flutter.dev](https://flutter.dev/docs/get-started/install)
- For Android: Java 17 + Android SDK
- For Windows: Visual Studio 2022 with "Desktop development with C++" workload

### Setup

```bash
# Clone the repository
git clone https://github.com/PetersDigital/pomer.git
cd pomer

# Install dependencies
flutter pub get

# Run on your connected device / emulator
flutter run
```

### Building

```bash
# Android APK (debug)
flutter build apk --debug

# Web
flutter build web

# Windows
flutter build windows
```

### Clean Build
If you encounter caching issues, generated file conflicts, or stale dependencies, perform a clean build:

```bash
# Clean the flutter build cache
flutter clean

# Re-fetch dependencies
flutter pub get

# Re-generate Riverpod provider code
dart run build_runner build --delete-conflicting-outputs
```

### Running Tests

```bash
flutter test
```

### Linting

```bash
flutter analyze --fatal-infos
```

---

## Future Ideas (Post v1.0.0)

> **Note:** The following features are part of an ideaboard and are *not guaranteed* to be implemented. They represent potential paths for extending the app after the core `v1.0.0` release.

- **Session Target Configurations:** A feature allowing users to set a specific target number of full pomodoro sessions (cycles) to complete per day.
- *(More ideas will be added here as the project evolves)*

---

## Screenshots

> _Screenshots will be added in v0.8.0._

---

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for a detailed description of the project structure, state management approach, navigation, and coding conventions.

---

## Credits

**Developer:** Dencel K Babu  
**Company:** [PetersDigital](https://github.com/PetersDigital)

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.