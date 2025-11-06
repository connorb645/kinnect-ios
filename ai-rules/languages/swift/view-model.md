# view-model.md — Swift Presentation/State Patterns

<tags>
scope: language
language: swift
project: any
domain: view-model
keywords: reducer, state, effects, async, Swift Concurrency
</tags>

<primary_directive>
Model state and actions explicitly. Keep reducers pure and isolate effects with cancellation support. Inject clients for testability.
</primary_directive>

<pattern name="reducer_pseudocode">
enum Action { case load, loaded([Item]), failed(String) }
struct State { var items: [Item] = []; var loading = false; var error: String? }

func reduce(_ state: inout State, _ action: Action) -> Effect? {
  switch action {
  case .load:
    state.loading = true; state.error = nil; return .fetchItems
  case let .loaded(items):
    state.loading = false; state.items = items; return nil
  case let .failed(msg):
    state.loading = false; state.error = msg; return nil
  }
}
</pattern>

<checklist>
☐ All transitions explicit; no hidden state changes
☐ Effects cancellable and idempotent
☐ Services injected; no singletons
☐ Reducers unit-tested
</checklist>

