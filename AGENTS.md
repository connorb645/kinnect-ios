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

## Testing Guidelines
- Frameworks: XCTest, XCUITest. Place unit tests in `iosTests`, UI in `iosUITests`.
- Naming: `test_<UnitUnderTest>_<Behavior>_<Expectation>()`.
- Run: `make test SCHEME=YourScheme DESTINATION='platform=iOS Simulator,name=iPhone 15'`.
- Aim to cover view models, services, routing logic (`NavigationRouter`).

## Commit & Pull Request Guidelines
- Commits: Imperative, concise subject (<72 chars), meaningful body. Conventional Commits (e.g., `feat:`, `fix:`) encouraged.
- PRs: Clear description, link issues, include screenshots for UI changes, note risk/rollout.
- Keep diffs focused; include tests and docs updates when applicable.

## Security & Configuration Tips
- Do not commit secrets. Use Keychain for tokens; keep env‑specific values in `ios/Resources/Config/*.xcconfig`.
- `Pods/` is ignored; commit `Podfile.lock`. Keep `Package.resolved` for SPM reproducibility.
