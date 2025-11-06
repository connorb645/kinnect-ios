# view-model.md — Presentation/State Patterns

<tags>
scope: general
language: any
project: any
domain: view-model
keywords: state, reducer, action, effect, presenter, controller, async
</tags>

<primary_directive>
Centralize state and side-effects in a testable presentation layer. Keep updates explicit, effects well-defined, and inputs/outputs typed.
</primary_directive>

<cognitive_anchors>
TRIGGERS: viewmodel, presenter, controller, reducer, state, action, effect, async
SIGNAL: Apply all rules when coordinating UI state and effects.
</cognitive_anchors>

<rule_1 priority="HIGHEST">
EXPLICIT STATE MACHINE
- Define State and Actions; enumerate transitions.
- Represent loading/error/empty as explicit states.
- Avoid derived duplicates; compute from source of truth.
</rule_1>

<rule_2 priority="HIGH">
SIDE-EFFECTS AS EFFECTS
- Isolate I/O in effect handlers; keep reducers pure.
- Support cancellation and idempotency for async tasks.
- Thread-safe updates; avoid data races.
</rule_2>

<rule_3 priority="HIGH">
TESTABILITY & DI
- Inject services/clients; substitute fakes in tests.
- Deterministic scheduling and time via injected clocks/schedulers.
- No hidden singletons/globals.
</rule_3>

<pattern name="reducer_style">
// Pseudocode
type State = { items: Item[]; loading: boolean; error?: string }
type Action = { type: 'load' } | { type: 'loaded'; items: Item[] } | { type: 'failed'; error: string }

function reduce(state: State, action: Action): [State, Effect?] {
  switch (action.type) {
    case 'load':
      return [{ ...state, loading: true, error: undefined }, { type: 'fetchItems' }]
    case 'loaded':
      return [{ ...state, loading: false, items: action.items }]
    case 'failed':
      return [{ ...state, loading: false, error: action.error }]
  }
}
</pattern>

<pattern name="effects_with_cancellation">
// Pseudocode
const effects = {
  fetchItems: async (env, send, token) => {
    try { send({ type: 'loaded', items: await env.api.list(token) }) }
    catch (e) { send({ type: 'failed', error: toMessage(e) }) }
  }
}
</pattern>

<checklist>
☐ All actions handled; no fallthrough
☐ Reducer pure; effects isolated
☐ Cancellation/idempotency for async
☐ Services injected; no globals
☐ Derived state computed, not stored
</checklist>

<avoid>
❌ View models doing network calls directly in property getters
❌ Hidden mutable singletons
❌ Duplicated derived flags (e.g., isEmpty + items.count == 0)
❌ Leaky abstractions coupling UI to transport/storage
</avoid>

<review>
- Unit-test reducers and effect wiring
- Verify no race conditions under concurrency
- Ensure clear separation from UI layer
</review>
