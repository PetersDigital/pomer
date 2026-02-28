# AGENTS.md — LLM Development Contract

This file defines strict rules for automated contributors (GitHub Copilot, Google Jules, or other LLM agents).

Agents must follow these rules without deviation.

---

# 1. Versioning & Commit Discipline

We follow:

- Semantic Versioning (SemVer)
- Conventional Commits
- Signed annotated Git tags

## 1.1 DO NOT include version numbers in commit subjects

❌ Wrong:
feat: implement v0.4.0 audio feature

✅ Correct:
feat(audio): add alarm playback support

Version numbers belong ONLY in:
- Git tags (v0.4.0)
- CHANGELOG
- Release titles
- README roadmap

Never in commit subjects.

---

## 1.2 PR Flow

- Feature PR → merged normally
- Final merge commit may be:
  feat(audio): add alarm and notification system
- Version bump is performed via signed tag, NOT via commit message

---

# 2. Architecture Rules

Agents MUST read:

- README.md
- ARCHITECTURE.md

Before modifying code.

## 2.1 Feature Isolation

- No feature may import another feature directly.
- Shared logic must go into `core/`.

## 2.2 State Management

- Riverpod v2
- Prefer code generation for new providers
- Use:
  ref.watch() in build
  ref.read() in callbacks

## 2.3 Lints Are Mandatory

These must not be violated:

- prefer_const_constructors
- require_trailing_commas
- avoid_print
- prefer_single_quotes
- prefer_final_locals

CI will fail if violated.

---

# 3. Release Process

Releases are triggered ONLY by signed tags.

Example:

git tag -s v0.4.0 -m "Release v0.4.0 — Audio & Notifications"
git push origin v0.4.0

Tag format must match:

vMAJOR.MINOR.PATCH

Example:
v0.3.0

---

# 4. CI Expectations

When a tag is pushed:

- Build with --release
- Build targets:
  - Android (APK)
  - Web (wasm + standard)
  - Windows
- Upload artifacts to GitHub Release

Debug builds may optionally be pushed to Telegram (see CI config).

---

# 5. Platform Scope

Supported:
- Android (primary)
- Windows
- Web

Not supported:
- iOS
- macOS
- Linux

Agents must not add platform code outside scope.

---

# 6. Stability Rules

The app is considered:

- v0.3.0 → basic usable state
- v1.0.0 → production ready

Breaking architectural changes require:
- MAJOR version bump
- Explicit documentation update

---

# 7. Agents Must Not

- Modify CI without explicit reason
- Change Application ID
- Downgrade SDK targets
- Remove strict lints
- Introduce cross-feature coupling