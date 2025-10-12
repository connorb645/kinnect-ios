# iOS Project Structure

This repository uses a modular, feature-first structure. Folders and sample placeholders are provided so Git tracks empty directories. Adjust to match your architecture (MVC/MVVM/Clean, UIKit/SwiftUI).

Top-level folders
- `App`: App composition root (app entry, DI wiring, routing).
- `Features`: User-facing features (screens, view models, feature-specific models).
- `Network`: HTTP clients, API definitions, DTOs, middleware.
- `Common`: Reusable UI components, extensions, utilities, styles, protocols.
- `Persistence`: Storage layers (UserDefaults, Keychain, Core Data).
- `Services`: Cross-cutting services (Analytics, Push, Remote Config, etc.).
- `Resources`: Assets, strings, fonts, and build configs (`.xcconfig`).
- `Tests`: Unit, UI, and snapshot tests.
- `Scripts`: Developer and CI scripts.

Notes
- `.gitkeep` files ensure directories remain in Git even if empty.
- `.xcconfig` files under `Resources/Config` can be referenced from Xcode build settings per configuration.
- Feel free to remove folders you don’t need, or expand with additional modules (e.g., `DesignSystem`, `Experimentation`).

