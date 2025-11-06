# view.md — UI/View Patterns

<tags>
scope: general
language: any
project: any
domain: view
keywords: UI, UX, view, component, render, state, layout, accessibility, performance
</tags>

<primary_directive>
Build accessible, performant, and predictable views. Keep UI declarative and thin; move logic to state/presentation layers. Render from state; trigger effects via explicit actions.
</primary_directive>

<cognitive_anchors>
TRIGGERS: UI, view, component, layout, render, accessibility, performance, state, event
SIGNAL: Apply all rules when creating or refactoring UI components.
</cognitive_anchors>

<rule_1 priority="HIGHEST">
DECLARATIVE & UNIDIRECTIONAL
- Derive UI from state; no hidden reads/writes.
- Emit user intents as actions; do not perform I/O directly in views.
- Keep views pure where possible.
</rule_1>

<rule_2 priority="HIGH">
ACCESSIBILITY & UX
- Provide labels, roles, and focus order.
- Support keyboard/screen reader navigation.
- Respect motion/contrast preferences.
</rule_2>

<rule_3 priority="HIGH">
PERFORMANCE
- Avoid unnecessary re-renders; key lists; memoize heavy subtrees.
- Defer expensive work off the critical path.
- Use virtualization/lazy loading for large collections.
</rule_3>

<pattern name="state_driven_render">
// Pseudocode
function View(state, send) {
  if (state.loading) return Spinner()
  if (state.error) return ErrorView(state.error, () => send({ type: 'retry' }))
  return List(state.items.map(item => Row(item, () => send({ type: 'tap', id: item.id }))))
}
</pattern>

<pattern name="list_keys_and_memo">
// Pseudocode
List(items, key = item => item.id, render = memo(Row))
</pattern>

<checklist>
☐ Derived from state; no hidden effects
☐ A11y labels/roles and focus order
☐ Loading/empty/error states covered
☐ Lists keyed; heavy subtrees memoized
☐ No blocking work on render path
</checklist>

<avoid>
❌ Business logic in views
❌ Imperative DOM/UI mutations where declarative exists
❌ Hidden network/disk access from event handlers without state coordination
</avoid>

<review>
- Verify a11y with keyboard/screen reader
- Profile re-render hot paths
- Confirm states and transitions are complete
</review>
