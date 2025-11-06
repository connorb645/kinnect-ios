# testing.md — Swift Testing Conventions

<tags>
scope: language
language: swift
project: any
domain: testing
keywords: swift testing, XCTest, swift-testing, async, clock, dependency injection
</tags>

<primary_directive>
Use deterministic, fast tests. Inject clocks/schedulers, avoid sleeps and real network. Prefer Swift Testing (`@Test`) where available, or XCTest with clear AAA structure.
</primary_directive>

<pattern name="with_dependencies_style">
// Example with dependency injection style
@Test
func tokenExpiresAfter15m() async throws {
  let t0 = Date(timeIntervalSince1970: 0)
  let clock = TestClock(now: t0)
  let svc = Service(clock: clock)
  let token = svc.issueToken()
  #expect(token.expiration == t0.addingTimeInterval(15 * 60))
}
</pattern>

<checklist>
☐ Async tests avoid sleeps; use clocks
☐ Pure logic tested via values, not side-effects
☐ Test doubles for networking and persistence
☐ Small, named helpers for fixtures
</checklist>

