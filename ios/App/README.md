# App

Composition root for the application. Suggested contents:
- App entry (e.g., `KinnectApp.swift` for SwiftUI or `AppDelegate`/`SceneDelegate` for UIKit).
- Dependency container setup.
- Root navigation/router wiring.

Observation note
- Prefer Swift's `@Observable` (Observation framework) over `ObservableObject`/`@ObservedObject`/`@StateObject`.
- Hold observable models in SwiftUI using `@State var model = Model()` and pass as needed.
