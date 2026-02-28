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