# testing.md — Test Strategy & Conventions

<tags>
scope: general
language: any
project: any
domain: testing
keywords: test, unit, integration, e2e, fixture, mock, stub, coverage
</tags>

<primary_directive>
Prefer fast, deterministic tests with clear intent. Test behavior, not implementation. Optimize for signal, maintainability, and developer speed.
</primary_directive>

<cognitive_anchors>
TRIGGERS: test, unit, integration, e2e, fixture, mock, stub, coverage, flaky, regression
SIGNAL: Apply all rules before writing or modifying tests.
</cognitive_anchors>

<rule_1 priority="HIGHEST">
CLARIFY SCOPE & TYPE
- Choose the smallest effective scope (unit > integration > e2e).
- Define the observable behavior and success criteria first.
- Identify external effects (network/fs/time/threads) and isolate them.
</rule_1>

<rule_2 priority="HIGH">
DETERMINISM & ISOLATION
- Use DI/fakes to control time, randomness, I/O, and concurrency.
- Avoid network and real file system unless explicitly integration/e2e.
- No sleeps; use clocks/schedulers and signals.
</rule_2>

<rule_3 priority="HIGH">
STRUCTURE & READABILITY
- Arrange–Act–Assert with clear sections and meaningful names.
- One behavior per test; avoid broad assertions.
- Prefer property/example-based tests where valuable.
</rule_3>

<rule_4 priority="MEDIUM">
COVERAGE WITH PURPOSE
- Cover happy paths and edge cases (nil/empty/invalid/timeout).
- Test public APIs and externally visible behavior.
- Add regression tests for fixed bugs.
</rule_4>

<pattern name="fake_clock_and_scheduler">
// Pseudocode
interface Clock { now(): Time }
class TestClock implements Clock { /* controllable time */ }

test("token expires after 15m", () => {
  const t0 = parseTime("2025-01-01T00:00:00Z")
  const clock = new TestClock(t0)
  const svc = new Service(clock)
  const token = svc.issueToken()
  expect(token.expiresAt).toEqual(t0.plusMinutes(15))
})
</pattern>

<pattern name="arrange_act_assert">
// Arrange
const repo = new InMemoryRepo()
// Act
const result = useCase.run(input)
// Assert
expect(result).toEqual(expected)
</pattern>

<checklist>
☐ AAA structure; clear names
☐ Deterministic (no sleep, random, wall-clock)
☐ External I/O isolated or explicitly integration
☐ Edge cases covered; regressions locked in
☐ Tests fast and parallelizable
☐ Minimal mocking; prefer fakes at boundaries
</checklist>

<avoid>
❌ Testing private/internal details and brittle mocks
❌ Global mutable state across tests
❌ Real network/files unintentionally
❌ Sleeping to wait for async
</avoid>

<review>
- Run tests locally; ensure reliability and speed
- Eliminate flakes; document known limitations
- Keep fixtures minimal and explicit
</review>
