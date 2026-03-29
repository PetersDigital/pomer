# Pomer Testing Guide

This guide explains how to run, write, and maintain automated tests for the Pomer application.

## Running Tests

To execute the entire test suite:

```bash
flutter test
```

To run with coverage generation:

```bash
flutter test --coverage
```

## Testing Architecture

Our test suite is divided into three primary categories under the `test/` directory:

1. **`database/`**: Tests for data access objects (DAOs), repositories, and Drift queries.
2. **`features/`**: Tests for business logic and state management (Riverpod Notifiers).
3. **`features/ui/`**: Widget tests that verify the UI behavior and interaction.
4. **`helpers/`**: Common mocks and test container setups.

### Core Mocks and Test Containers

We use `mockito` to generate mocks for hardware and platform-specific services (e.g., Audio, Notifications).

The `test_helpers.dart` file provides a `createTestContainer` utility. This creates a `ProviderContainer` with:
- An in-memory SQLite database (`NativeDatabase.memory()`) for fast and isolated tests without writing to disk.
- Overrides for common dependencies to ensure tests are deterministic.

**To generate or update mocks, run:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Writing Tests

### 1. Database & Repository Tests
- **Setup**: Always use `createTestContainer()` which defaults to an in-memory database.
- **Teardown**: Make sure to call `await db.close()` in your `tearDown` blocks to clean up the in-memory database after each test.
- **Example**: See `test/database/tasks_repository_test.dart`

### 2. State Management Tests (Riverpod Notifiers)
- **Setup**: Read the notifier via the test container.
- **Teardown**: Always call `container.dispose()` at the end of the test to prevent state leakage and ensure listeners are cleaned up.
- **Example**: See `test/features/timer/timer_notifier_test.dart`

### 3. Widget Tests
- **Setup**: Wrap the widget under test in an `UncontrolledProviderScope` to supply your test container.
- **Async Operations**: Be extremely careful with genuine timers and platform method channels.
  - If a widget starts a real timer (e.g., `TimerScreen` starting a Pomodoro session), use `tester.runAsync(() async { ... })` for the interaction, followed by `await tester.pump()`.
  - Always clean up active timers before the end of the test (e.g., by tapping "Pause" or "Reset").
- **Animations and Streams**: Use `await tester.pumpAndSettle()` or explicit delays (`await tester.pump(const Duration(milliseconds: ...))`) to wait for `StreamProvider`s or animations to complete.

## Strict Linting Rules

All tests must adhere to the same strict linting rules as the main application code (defined in `AGENTS.md`):
- Use `const` constructors.
- Use trailing commas.
- Use `final` locals.
- Use single quotes.
- No `print()` statements.

Ensure you verify your tests against the linter:
```bash
flutter analyze --fatal-infos
```
