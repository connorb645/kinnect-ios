# view.md — SwiftUI View Patterns

<tags>
scope: language
language: swift
project: any
domain: view
keywords: SwiftUI, View, accessibility, performance, lists
</tags>

<primary_directive>
Keep SwiftUI views declarative and data-driven. Derive body from state, avoid hidden side-effects, and keep heavy work off the main thread.
</primary_directive>

<rule_1 priority="HIGH">
COMPOSITION & IDENTITY
- Break large views into small components.
- Use stable `id` for lists; prefer `Identifiable` models.
- Memoize expensive subviews with computed properties.
</rule_1>

<pattern name="state_driven_swiftui">
struct ContentView: View {
  let state: State
  let send: (Action) -> Void
  var body: some View {
    Group {
      if state.loading { ProgressView() }
      else if let error = state.error { ErrorView(error: error) }
      else { List(state.items) { Row(item: $0) } }
    }
    .refreshable { send(.refresh) }
  }
}
</pattern>

<checklist>
☐ No blocking work on main thread
☐ States: loading/empty/error covered
☐ Accessibility labels and traits set
☐ Lists keyed; performance verified
</checklist>

