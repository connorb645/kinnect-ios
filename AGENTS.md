# Repository Guidelines

## Project Structure & Module Organization
- App code lives under `ios/` using a feature‑first layout:
  - `ios/App` (entry, composition), `ios/Features` (feature modules), `ios/Navigation` (enum‑driven routing), `ios/Network`, `ios/Common`, `ios/Services`, `ios/Persistence`, `ios/Resources` (assets, `.xcconfig`).
  - Tests: `iosTests`, `iosUITests`. Scripts: `ios/Scripts`.
- Navigation: `AppRoute` + `NavigationRouter` (`@Observable`) drive a `NavigationStack`.

## Build, Test, and Development Commands
- `make help`: Show available targets and config.
- `make bootstrap`: chmod scripts, install Bundler/Pods if present, resolve SPM.
- `make open`: Open detected `.xcworkspace`/`.xcodeproj`.
- `make build [SCHEME=...] [CONFIGURATION=Debug]`: Build via `xcodebuild`.
- `make test [SCHEME=...] [DESTINATION=...]`: Run tests with code coverage.
- `make archive [SCHEME=...]`: Create a Release archive.
- `make lint` / `make format`: Run SwiftLint/swift‑format if installed; see `ios/Scripts`.

## Coding Style & Naming Conventions
- Swift style: 4‑space indent, limit lines to ~120 cols.
- Prefer Swift Observation `@Observable` over `ObservableObject`/`@ObservedObject`/`@StateObject` for performance and simplicity.
- Naming: `UpperCamelCase` types, `lowerCamelCase` vars/functions, `SCREAMING_SNAKE_CASE` constants when appropriate.
- File placement mirrors domain (e.g., `ios/Features/Auth`, `ios/Common/Extensions`).

## Error Handling Preferences
- Prefer typed throws for public APIs: use `throws(CustomErrorType)` when functions can fail, so callsites explicitly handle the expected error domain.
- Define feature‑scoped error enums (e.g., `CalendarError`) and ensure throwing methods only throw that type.
- Keep throwing surface narrow; non‑failing queries should remain non‑throwing and async when future I/O is expected.

## Testing Guidelines
- Frameworks: Swift Testing (`import Testing`) for unit tests in `iosTests`. UI tests are optional and typically omitted unless requested.
- Naming: prefer descriptive test function names; when using XCTest, `test_...`; with Swift Testing, use `@Test func ...()`.
- Run: `make test SCHEME=YourScheme DESTINATION='platform=iOS Simulator,name=iPhone 15'`.
- Focus on business logic: stores, services, reducers, formatting, date math, routing logic. Avoid UI view rendering tests unless explicitly requested.
- Determinism: use fixed `Calendar` and `TimeZone` in date/time tests; avoid reliance on `Calendar.current` or device locale.
- Concurrency: mark actor‑isolated entry points with `@MainActor` when they mutate UI‑observed state; annotate tests accordingly.

## Plan → Tests → Implement Workflow
This repository prefers an explicit, iterative flow for new work. The assistant will:

1) Capture Work Brief
- The user describes the feature/bugfix at a high level (goals, constraints, success criteria).

2) Produce a Granular Plan
- Break the work into the smallest verifiable tasks possible (5–9 items typical).
- Tasks are implementation‑agnostic where helpful and sequenced to reduce risk.
- The plan is shared for confirmation before any code changes.

3) Draft Test Outlines First
- For each task that impacts business logic, write test cases as outlines (no implementation yet) using a Given/When/Then or Arrange/Act/Assert style.
- Scope: business logic only (stores, models, services, date math, reducers). UI rendering is out of scope unless explicitly requested.
- Determinism guidelines apply (fixed calendars/locales, pure functions where possible).
- The user reviews and approves or amends the test outlines.

4) Implement to the Tests
- Implement code changes narrowly to satisfy the approved test cases.
- Prefer typed throws with feature‑scoped error enums; keep async APIs where future I/O is likely.
- Keep diffs focused; update docs and formatters/utilities as needed.

5) Validate and Iterate
- Run the test suite locally; resolve failures; ensure actor isolation and date/time determinism.
- Provide a concise summary of changes and any notable trade‑offs.

6) Commit and Hand‑off
- Commit with a concise, imperative message referencing tests and scope.
- Offer next steps (follow‑ups, refactors, missing tests) for user decision.

## Commit & Pull Request Guidelines
- Commits: Imperative, concise subject (<72 chars), meaningful body. Conventional Commits (e.g., `feat:`, `fix:`) encouraged.
- PRs: Clear description, link issues, include screenshots for UI changes, note risk/rollout.
- Keep diffs focused; include tests and docs updates when applicable.

## Security & Configuration Tips
- Do not commit secrets. Use Keychain for tokens; keep env‑specific values in `ios/Resources/Config/*.xcconfig`.
- `Pods/` is ignored; commit `Podfile.lock`. Keep `Package.resolved` for SPM reproducibility.
