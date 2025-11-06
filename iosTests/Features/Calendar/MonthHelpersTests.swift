import Foundation
import Testing

@testable import ios

private let gmt = TimeZone(secondsFromGMT: 0)!
private var calGMT: Calendar {
  var c = Calendar(identifier: .gregorian)
  c.timeZone = gmt
  return c
}

private func d(_ y: Int, _ m: Int, _ day: Int) -> Date {
  var comps = DateComponents()
  comps.year = y
  comps.month = m
  comps.day = day
  return calGMT.date(from: comps)!
}

@MainActor
struct MonthHelpersTests {
  @Test func init_containing_normalizes_to_first_day_midnight() async throws {
    let cal = calGMT
    let date = cal.date(bySettingHour: 15, minute: 30, second: 0, of: d(2025, 1, 18))!
    let month = Month(containing: date, calendar: cal)
    var comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: month.start)
    #expect(comps.year == 2025 && comps.month == 1 && comps.day == 1)
    #expect(comps.hour == 0 && comps.minute == 0)
  }

  @Test func navigation_and_grid_weeks_are_stable() async throws {
    let cal = calGMT
    let jan = Month(containing: d(2025, 1, 15), calendar: cal)
    let feb = jan.next
    let mar = feb.next
    #expect(cal.component(.month, from: jan.start) == 1)
    #expect(cal.component(.month, from: feb.start) == 2)
    #expect(cal.component(.month, from: mar.start) == 3)

    // Grid weeks should be 4-6 rows, 7 cols
    let rows = jan.gridWeeks
    #expect(rows.count >= 4 && rows.count <= 6)
    #expect(rows.allSatisfy { $0.count == 7 })
  }
}
