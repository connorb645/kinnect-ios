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

## Security & Configuration Tips
- Do not commit secrets. Use Keychain for tokens; keep env‑specific values in `ios/Resources/Config/*.xcconfig`.
- `Pods/` is ignored; commit `Podfile.lock`. Keep `Package.resolved` for SPM reproducibility.
