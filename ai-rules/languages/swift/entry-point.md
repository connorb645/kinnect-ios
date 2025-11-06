# entry-point.md — Swift Language Principles

<tags>
scope: language
language: swift
project: any
domain: general
keywords: swift, ios, swiftui, tca, combine, grdb
</tags>

<primary_directive>
Favor clarity and safety. Use value semantics and type system strength to prevent invalid states. Prefer protocol-oriented design and dependency injection for testability.
</primary_directive>

<rule_1 priority="HIGHEST">
LANGUAGE IDIOMS
- Prefer structs and enums; use classes when reference semantics are needed.
- Use optionals intentionally; avoid force unwraps (`!`, `try!`).
- Model domain with enums and associated values to make invalid states unrepresentable.
</rule_1>

<rule_2 priority="HIGH">
ERRORS & CONCURRENCY
- Prefer `throws` with typed domain errors or error enums.
- Use Swift Concurrency (`async/await`, `Task`, `TaskGroup`) when appropriate; cancel tasks explicitly.
- Avoid shared mutable state; use `actor`s for isolation where needed.
</rule_2>

<pattern name="dependency_injection">
protocol Clock { var now: Date { get } }
struct SystemClock: Clock { var now: Date { Date() } }

struct Service {
  var clock: Clock
  func issueToken() -> Token { .init(expiration: clock.now.addingTimeInterval(15*60)) }
}
</pattern>

<checklist>
☐ No force unwraps; safe error handling
☐ Value types by default; reference types when required
☐ Concurrency uses structured tasks and cancellation
☐ Public APIs documented and small
</checklist>
