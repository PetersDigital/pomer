# Pomer 🍅

> **A Pomodoro timer app for Android, Windows & Web.** Built with Flutter & Dart.

[![CI](https://github.com/PetersDigital/pomer/actions/workflows/ci.yml/badge.svg)](https://github.com/PetersDigital/pomer/actions/workflows/ci.yml)

---

## About

Pomer is a clean, Material 3 Pomodoro timer app designed to help you stay focused using the [Pomodoro Technique](https://en.wikipedia.org/wiki/Pomodoro_Technique). Work in focused 25-minute intervals, take short breaks, and track your progress — all in a beautiful, distraction-free interface.

---

## Feature Roadmap

| Version | Feature |
|---------|---------|
| **v0.1.0** ✅ | Project foundation — Flutter setup, navigation shell, theming |
| v0.2.0 | Pomodoro timer (countdown, session tracking, notifications) |
| v0.3.0 | Settings (custom durations, theme preference, persistence) |
| v0.4.0 | Task list (associate tasks with Pomodoro sessions) |
| v0.5.0 | Statistics (session history, charts) |
| v0.6.0 | Gamification (streaks, achievements, badges) |
| v1.0.0 | Production release |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | [Flutter](https://flutter.dev) (stable channel) |
| Language | Dart ≥ 3.0 |
| State Management | [Riverpod](https://riverpod.dev) v2 |
| Navigation | [GoRouter](https://pub.dev/packages/go_router) |
| Theming | Material 3 + [Google Fonts](https://pub.dev/packages/google_fonts) (Poppins) |
| Local Storage | [SharedPreferences](https://pub.dev/packages/shared_preferences) (v0.3.0+), Drift (v0.4.0+) |
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

### Running Tests

```bash
flutter test
```

### Linting

```bash
flutter analyze --fatal-infos
```

---

## Screenshots

> _Screenshots will be added in v0.9.0._

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
