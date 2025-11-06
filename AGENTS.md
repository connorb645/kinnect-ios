# Agent Guide
# Repository Guidelines

## Project Structure & Module Organization
- Source: `ios/` (SwiftUI). Feature-first layout: `Features/`, `Common/`, `Network/`, `Persistence/`, `Services/`, `Navigation/`, `Resources/` (assets, fonts, localizations, `.xcconfig`). App entry: `ios/iosApp.swift`, `ios/ContentView.swift`.
- Tests: `iosTests/` mirrored by feature (e.g., `iosTests/Features/Calendar/*`).
- Xcode: `ios.xcodeproj` (workspace optional). See `README_STRUCTURE.md` for folder intent.

## Build, Test, and Development Commands
- `make bootstrap`: Prepare local tools and dependencies (Pods/SPM if present).
- `make open`: Open the workspace/project in Xcode.
- `make build [SCHEME=YourScheme] [CONFIGURATION=Debug]`: Build the app.
- `make test [SCHEME=YourScheme] [DESTINATION="platform=iOS Simulator,name=iPhone 15,OS=latest"]`: Run tests with coverage.
- `make lint`: Run SwiftLint and swift-format if installed.
- `make format`: Apply `swift-format` recursively.
Tip: Schemes auto-detect; override with `SCHEME=...` when needed.

## Coding Style & Naming Conventions
- Swift 5.9+ with SwiftUI and Observation. Prefer 2-space indentation.
- Types: UpperCamelCase; methods/vars: lowerCamelCase; files match primary type (e.g., `CalendarStore.swift`).
- Lint/format: SwiftLint (optional) and `swift-format`. Keep views small and compose via subviews in `Features/*/Views`.

## Testing Guidelines
- Framework: Swift Testing (`import Testing`, `@Test`, `#expect`).
- Location: mirror feature folders under `iosTests/` and suffix files with `Tests.swift`.
- Run: `make test SCHEME=YourScheme` to execute with coverage enabled.
- Aim for fast, deterministic tests; avoid locale/timezone coupling (see existing date tests for patterns).

## Commit & Pull Request Guidelines
- Commits: Conventional format — `<type>(<scope>): summary` (types: feat, fix, refactor, test, docs, chore, ci, build, style, perf). Keep subjects ≤72 chars. Explain the “why” in the body; link issues.
- PRs: Clear description, screenshots for UI changes, test plan, and linked issues. Keep changes focused; update docs if patterns or scripts change.

## Security & Configuration
- Do not commit secrets. Use Keychain/secure storage and `.xcconfig` files under `ios/Resources/Config` for non-secret settings per build configuration.

Questions or ambiguities? Propose 2–3 options with trade-offs before implementing.
## Purpose
Agents act as senior engineering collaborators. Keep responses concise, clarify uncertainty before coding, propose 2–3 viable options with trade‑offs when design choices matter, and align all work with the rules referenced below.

## Rule Index
- ai-rules/rule-loading.md — always load this file first to decide which other rules to load.

## Repository Overview
- Project summary: SwiftUI iOS app with a feature-first structure. Current focus includes a Calendar feature (`CalendarStore`, `Day`, `Month`, `CalendarEntry`) with Swift Concurrency and typed errors.
- Key modules/packages: Native Swift + SwiftUI + Observation. Optional tooling: SwiftLint, `swift-format`. No third-party runtime dependencies required to build.
- Directory layout: App entry/bootstrapping in `ios/` (`iosApp.swift`, `ContentView.swift`); features in `ios/Features/*`; shared code in `ios/Common`; networking stubs in `ios/Network`; navigation in `ios/Navigation`; assets/configs in `ios/Resources`; tests in `iosTests/`.

## Commands
- Common tasks: `make bootstrap`, `make open`, `make build`, `make test`, `make lint`, `make format`.
- How to run locally: `make bootstrap && make open` (or `make build SCHEME=<YourScheme>`).
- How to run tests: `make test SCHEME=<YourScheme> DESTINATION="platform=iOS Simulator,name=iPhone 15,OS=latest"`.
- Useful one-liners:
  - Auto-detect scheme build: `make build`
  - Filter tests via xcodebuild: `xcodebuild ... -only-testing:iosTests/CalendarStoreTests/addEntry_sorts_and_returns`
  - Lint script (path): `bash ios/Scripts/lint.sh`

## Code Style
- Naming/formatting/comments: 2-space indentation; UpperCamelCase types; lowerCamelCase members; files named after primary type. Doc-comment public APIs; keep views small and composable.
- Error handling: Prefer typed errors (`throws(CalendarError)`) and `LocalizedError` messages. Avoid force unwraps/`try!`.
- Dependency injection: Initializer injection for stores/services; pass state via SwiftUI `@Environment` where appropriate.
- Complexity targets: Keep functions ≤ 50 lines, cyclomatic complexity ≤ 10; extract helpers early.

## Architecture & Patterns
- Core approach: Feature-first SwiftUI with observable state (`@Observable` store). MVVM-like separation with lightweight Views + Stores/Models.
- Boundaries/utilities: Feature code under `ios/Features/<Feature>/{Models,Views}`; cross-cutting utilities in `ios/Common`.
- Config/secrets/env: Use `.xcconfig` under `ios/Resources/Config` for non-secrets; store secrets in Keychain or CI secrets, never in Git.

## Key Integration Points
- Database: None by default; `ios/Persistence` reserved for future storage (UserDefaults/Keychain/Core Data).
- External services/APIs: Place clients and DTOs under `ios/Network/*`. Keep models decoupled from transport.
- Messaging/queues/jobs: Not used. If added, isolate behind a service in `ios/Services`.
- Observability: Use `os.Logger` for logs; consider signposts for performance. Keep PII out of logs.

## Workflow
- Ask for clarification when requirements are ambiguous; surface 2–3 options with trade‑offs when it helps decision making.
- Follow rule loading from `ai-rules/rule-loading.md` (progressive disclosure instead of loading everything at once).
- Update documentation (this file and relevant rule files) when introducing new patterns or services.
- Use clear, conventional commit messages (e.g., `<type>(<scope>): summary`).

## Testing
- Strategy: Unit-first with deterministic behavior; add integration tests where boundaries matter (e.g., date math). Avoid timezone/locale coupling (see existing tests).
- Run/filter: `make test SCHEME=<YourScheme>`; filter with `-only-testing:` in `xcodebuild` or Xcode’s test navigator.
- Data/fixtures: Prefer in-memory fakes and explicit helpers near tests (see date helper patterns in `iosTests/Features/Calendar/*`).

## Environment
- Tools/SDKs: Xcode 15+ (Swift 5.9+), iOS 17 Simulator, optional SwiftLint and `swift-format`.
- Local setup: Install Xcode + Command Line Tools, run `make bootstrap`, then `make open`.
- CI: Use `make ci` or `make test` with `SCHEME` and a valid simulator destination. Ensure linters are installed or skip gracefully.

## Special Notes
- Do not modify files outside the workspace root without explicit approval.
- Avoid destructive git operations unless explicitly requested by the user.
- Keep changes minimal, focused, and consistent with the existing style.
- When in doubt or making a significant choice, ask first.
