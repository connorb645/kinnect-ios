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
  @Test func day_overlaps_truth_table() async throws {
    let calendar = calGMT
    let dayStart = d(2025, 7, 10)
    let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
    let day = Day(dayStart, calendar: calendar)

    // Ends exactly at dayStart -> false
    #expect(day.overlaps(eventStartUTC: d(2025, 7, 9, 23, 0), eventEndUTC: dayStart) == false)
    // Starts exactly at dayEnd -> false
    #expect(
      day.overlaps(
        eventStartUTC: dayEnd,
        eventEndUTC: calendar.date(byAdding: .hour, value: 1, to: dayEnd)!
      ) == false)
    // Fully within -> true
    #expect(
      day.overlaps(
        eventStartUTC: d(2025, 7, 10, 9, 0), eventEndUTC: d(2025, 7, 10, 10, 0)
      ) == true)
    // Starts before / ends within -> true
    #expect(
      day.overlaps(
        eventStartUTC: d(2025, 7, 9, 23, 0), eventEndUTC: d(2025, 7, 10, 1, 0)
      ) == true)
    // Starts within / ends after -> true
    #expect(
      day.overlaps(
        eventStartUTC: d(2025, 7, 10, 23, 0), eventEndUTC: d(2025, 7, 11, 1, 0)
      ) == true)
    // Spans entire day -> true
    #expect(
      day.overlaps(
        eventStartUTC: d(2025, 7, 9, 12, 0), eventEndUTC: d(2025, 7, 11, 12, 0)
      ) == true)
  }
}
