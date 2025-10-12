# Navigation

Enum-driven navigation state with a shared router.

Note on Observation
- This project prefers Swift's Observation framework (`@Observable`) over `ObservableObject`/`@ObservedObject`/`@StateObject` for better performance and simpler state updates (iOS 17+/Swift 5.9+).
- `NavigationRouter` is annotated with `@Observable`; no `@Published` is needed.

SwiftUI usage sketch:

1) Hold a `NavigationRouter` instance in your composition root (e.g., `@State var router = NavigationRouter()`).
2) Bind `router.path` to a `NavigationStack` and provide `navigationDestination(for: AppRoute)` mappings.
3) Push/pop via `router.push(_:)`, `router.pop()`, `router.popToRoot()`.

Example
```swift
import SwiftUI
import Observation

struct RootView: View {
    @State private var router = NavigationRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .auth: AuthView()
                    case .home: HomeView()
                    case .profile(let id): ProfileView(id: id)
                    case .settings: SettingsView()
                    }
                }
        }
    }
}
```
