import Foundation
import Testing

@testable import ios

private let gmt = TimeZone(secondsFromGMT: 0)!
private var calGMT: Calendar {
  var c = Calendar(identifier: .gregorian)
  c.timeZone = gmt
  return c
}

private func d(_ y: Int, _ m: Int, _ day: Int, _ h: Int = 0, _ min: Int = 0) -> Date {
  var comps = DateComponents()
  comps.year = y
  comps.month = m
  comps.day = day
  comps.hour = h
  comps.minute = min
  return calGMT.date(from: comps)!
}

@MainActor
struct ModelsTests {
  @Test func day_contains_overlap_truth_table() async throws {
    let calendar = calGMT
    let dayStart = d(2025, 7, 10)
    let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
    let day = Day(date: dayStart)

    // Ends exactly at dayStart -> false
    #expect(
      day.contains(
        CalendarEntry(title: "A", startDate: d(2025, 7, 9, 23, 0), endDate: dayStart),
        calendar: calendar) == false)
    // Starts exactly at dayEnd -> false
    #expect(
      day.contains(
        CalendarEntry(
          title: "B", startDate: dayEnd,
          endDate: calendar.date(byAdding: .hour, value: 1, to: dayEnd)!), calendar: calendar)
        == false)
    // Fully within -> true
    #expect(
      day.contains(
        CalendarEntry(title: "C", startDate: d(2025, 7, 10, 9, 0), endDate: d(2025, 7, 10, 10, 0)),
        calendar: calendar) == true)
    // Starts before / ends within -> true
    #expect(
      day.contains(
        CalendarEntry(title: "D", startDate: d(2025, 7, 9, 23, 0), endDate: d(2025, 7, 10, 1, 0)),
        calendar: calendar) == true)
    // Starts within / ends after -> true
    #expect(
      day.contains(
        CalendarEntry(title: "E", startDate: d(2025, 7, 10, 23, 0), endDate: d(2025, 7, 11, 1, 0)),
        calendar: calendar) == true)
    // Spans entire day -> true
    #expect(
      day.contains(
        CalendarEntry(title: "F", startDate: d(2025, 7, 9, 12, 0), endDate: d(2025, 7, 11, 12, 0)),
        calendar: calendar) == true)
  }
}
