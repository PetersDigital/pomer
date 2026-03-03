# Contributing

## Branch Strategy

- `main` is protected and represents stable state.
- All development must occur in feature branches.
- CI runs on all branches except `main`.

Branch naming examples:

- feature/timer-audio
- fix/session-reset
- refactor/settings-state
- docs/architecture-update

---

## Commit Convention

This project follows Conventional Commits.

Format:

type(scope): subject

Rules:

- Subject must be imperative.
- No version numbers in feature subjects.
- Scope must reflect domain (timer, settings, android, ci, docs, etc).
- Versioning belongs only to signed tags.

Examples:

feat(timer): add audio notification support  
fix(settings): correct preset serialization  
docs(agents): define LLM governance rules  

---

## Release Process

Releases are created via signed annotated tags:

git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin vX.Y.Z

Tag push will later trigger release builds (not yet enabled).

### Pre-Release Checks (Branch Finalization)

Run these checks before creating the final PR commit or tagging a release.

1. Define the exact change range:

```bash
git log --oneline --reverse <start_sha>..<end_sha>
git diff --name-status <start_sha>..<end_sha>
```

2. Update release documentation:
- Add/update the release section in `CHANGELOG.md` from the commit range.
- Ensure roadmap/version status in `README.md` and `ARCHITECTURE.md` is correct.
- Update `AGENTS.md` only when new hard-earned guardrails are discovered.

3. Verify version consistency:
- `pubspec.yaml` version (e.g., `0.4.0+4`)
- `lib/core/constants/app_constants.dart` (`appVersion`)
- Android local/build values (`flutter.versionName`, `flutter.versionCode`)

4. Run quality/build checks:

```bash
flutter analyze --fatal-infos
flutter test
flutter build web
flutter build windows --debug
```

5. Smoke run critical targets:

```bash
flutter run -d windows
flutter run -d <android-device-id>
```

6. Finalize commit scope:

```bash
git status --short
```

- Commit only intended files with Conventional Commit messages.
- Keep lockfile-only churn out unless intentionally part of the release.

---

## CI Behavior

On every push to non-main branches:

- Static analysis
- Unit tests
- Debug builds (Android/Web/Windows)
- Release split arm64 APK
- APK automatically sent to Telegram for internal testing

APK filename format:

app-<branch>-<shortsha>.apk

---

## Security

- Telegram tokens are stored in GitHub Secrets.
- Never commit secrets.
- Never echo secrets in logs.

---

## Android Runtime Logs (Windows PowerShell 7)

For debugging app behavior on Android (wireless ADB or Android Studio emulator), use:

```powershell
adb logcat -c
$pkg = 'com.petersdigital.pomer'
$appPid = (adb shell pidof -s $pkg).Trim()
adb logcat --pid=$appPid -v time
```

Severity filters:

```powershell
adb logcat --pid=$appPid -v time '*:W'
adb logcat --pid=$appPid -v time '*:E'
```

Important: use `$appPid` (not `$PID`, which is read-only in PowerShell).

---

## Flutter Clean Lock Errors (Windows)

If `flutter clean` fails because `build/` is in use, run:

```powershell
.\android\gradlew --stop
taskkill /F /IM java.exe /T
taskkill /F /IM dart.exe /T
flutter clean
```

If still locked, delete only the `build/` folder manually and then run:

```powershell
flutter pub get
```

---

## Windows Bundling Guardrail

- Do not force `CMAKE_INSTALL_PREFIX` in `windows/CMakeLists.txt`.
- Flutter run/debug expects runtime DLL staging beside the runner executable.
- Overriding the install prefix can cause plugin DLL startup errors on Windows.