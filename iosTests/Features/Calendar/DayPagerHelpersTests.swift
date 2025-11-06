import Foundation
import Testing

@testable import ios

private let gmt = TimeZone(secondsFromGMT: 0)!
private var calGMT: Calendar {
  var c = Calendar(identifier: .gregorian)
  c.timeZone = gmt
  return c
}

private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
  var comps = DateComponents()
  comps.year = y
  comps.month = m
  comps.day = d
  return calGMT.date(from: comps)!
}

@MainActor
struct DayPagerHelpersTests {
  @Test func daysInRange_is_inclusive_and_sorted() async throws {
    let cal = calGMT
    let a = Day(date(2025, 1, 10), calendar: cal)
    let b = Day(date(2025, 1, 13), calendar: cal)
    let forward = DayPagerView<DayView>.daysInRange(start: a, end: b)
    let backward = DayPagerView<DayView>.daysInRange(start: b, end: a)

    #expect(forward.count == 4)  // 10, 11, 12, 13
    #expect(backward == forward)
    #expect(forward.first == a && forward.last == b)
  }

  @Test func clamp_bounds_and_passthrough() async throws {
    let cal = calGMT
    let start = Day(date(2025, 2, 1), calendar: cal)
    let end = Day(date(2025, 2, 3), calendar: cal)
    let days = DayPagerView<DayView>.daysInRange(start: start, end: end)

    // Below start -> clamp to start
    let below = Day(date(2025, 1, 31), calendar: cal)
    #expect(DayPagerView<DayView>.clamp(below, to: days) == start)

    // Above end -> clamp to end
    let above = Day(date(2025, 2, 4), calendar: cal)
    #expect(DayPagerView<DayView>.clamp(above, to: days) == end)

    // Inside -> passthrough
    let mid = Day(date(2025, 2, 2), calendar: cal)
    #expect(DayPagerView<DayView>.clamp(mid, to: days) == mid)
  }
}

