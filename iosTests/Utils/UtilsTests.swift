import Foundation
import Testing

@testable import ios

@MainActor
struct UtilsTests {
  @Test func array_safe_subscript_in_bounds_and_oob() async throws {
    let arr = [10, 20, 30]
    #expect(arr[safe: 0] == 10)
    #expect(arr[safe: 2] == 30)
    #expect(arr[safe: 3] == nil)
    #expect(arr[safe: -1] == nil)
  }

  @Test func calendar_formatters_emit_strings() async throws {
    // We don't assert exact text to avoid locale/timezone coupling; just non-empty for a valid date.
    let date = Date(timeIntervalSince1970: 0)
    #expect(!CalendarFormatters.monthHeader.string(from: date).isEmpty)
    #expect(!CalendarFormatters.dayFull.string(from: date).isEmpty)
    #expect(!CalendarFormatters.timeShort.string(from: date).isEmpty)
  }

  // MARK: - Date Extensions

  @Test func date_normalized_defaultsToNoon() async throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!

    var components = DateComponents()
    components.year = 2025
    components.month = 6
    components.day = 15
    components.hour = 9
    components.minute = 30
    components.second = 45
    let originalDate = calendar.date(from: components)!

    let normalized = originalDate.normalized(calendar: calendar)

    let resultComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: normalized)
    #expect(resultComponents.year == 2025)
    #expect(resultComponents.month == 6)
    #expect(resultComponents.day == 15)
    #expect(resultComponents.hour == 12)
    #expect(resultComponents.minute == 0)
    #expect(resultComponents.second == 0)
  }

  @Test func date_normalized_customHourAndMinute() async throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!

    var components = DateComponents()
    components.year = 2025
    components.month = 3
    components.day = 20
    components.hour = 14
    components.minute = 30
    let originalDate = calendar.date(from: components)!

    let normalized = originalDate.normalized(toHour: 8, minute: 15, calendar: calendar)

    let resultComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: normalized)
    #expect(resultComponents.year == 2025)
    #expect(resultComponents.month == 3)
    #expect(resultComponents.day == 20)
    #expect(resultComponents.hour == 8)
    #expect(resultComponents.minute == 15)
  }

  @Test func date_normalized_preservesDayMonthYear() async throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!

    var components = DateComponents()
    components.year = 2024
    components.month = 12
    components.day = 31
    components.hour = 23
    components.minute = 59
    components.second = 59
    let originalDate = calendar.date(from: components)!

    let normalized = originalDate.normalized(toHour: 0, minute: 0, calendar: calendar)

    let resultComponents = calendar.dateComponents([.year, .month, .day], from: normalized)
    #expect(resultComponents.year == 2024)
    #expect(resultComponents.month == 12)
    #expect(resultComponents.day == 31)
  }

  @Test func date_normalized_resetsSecondsAndNanoseconds() async throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!

    var components = DateComponents()
    components.year = 2025
    components.month = 1
    components.day = 1
    components.hour = 10
    components.minute = 30
    components.second = 45
    components.nanosecond = 123_456_789
    let originalDate = calendar.date(from: components)!

    let normalized = originalDate.normalized(calendar: calendar)

    let resultComponents = calendar.dateComponents([.second, .nanosecond], from: normalized)
    #expect(resultComponents.second == 0)
    #expect(resultComponents.nanosecond == 0)
  }

  @Test func date_normalized_midnightEdgeCase() async throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!

    var components = DateComponents()
    components.year = 2025
    components.month = 1
    components.day = 1
    components.hour = 0
    components.minute = 0
    let originalDate = calendar.date(from: components)!

    let normalized = originalDate.normalized(toHour: 0, minute: 0, calendar: calendar)

    let resultComponents = calendar.dateComponents([.hour, .minute], from: normalized)
    #expect(resultComponents.hour == 0)
    #expect(resultComponents.minute == 0)
  }

  @Test func date_normalized_endOfDayEdgeCase() async throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!

    var components = DateComponents()
    components.year = 2025
    components.month = 1
    components.day = 1
    components.hour = 23
    components.minute = 59
    let originalDate = calendar.date(from: components)!

    let normalized = originalDate.normalized(toHour: 23, minute: 59, calendar: calendar)

    let resultComponents = calendar.dateComponents([.hour, .minute], from: normalized)
    #expect(resultComponents.hour == 23)
    #expect(resultComponents.minute == 59)
  }

  @Test func date_normalized_differentCalendars() async throws {
    let gregorian = Calendar(identifier: .gregorian)
    let iso8601 = Calendar(identifier: .iso8601)

    var components = DateComponents()
    components.year = 2025
    components.month = 6
    components.day = 15
    components.hour = 14
    components.minute = 30
    let originalDate = gregorian.date(from: components)!

    let normalizedGregorian = originalDate.normalized(toHour: 12, minute: 0, calendar: gregorian)
    let normalizedISO8601 = originalDate.normalized(toHour: 12, minute: 0, calendar: iso8601)

    let gregorianComponents = gregorian.dateComponents([.hour, .minute], from: normalizedGregorian)
    let iso8601Components = iso8601.dateComponents([.hour, .minute], from: normalizedISO8601)

    #expect(gregorianComponents.hour == 12)
    #expect(gregorianComponents.minute == 0)
    #expect(iso8601Components.hour == 12)
    #expect(iso8601Components.minute == 0)
  }

  @Test func date_normalized_sameDateDifferentTimes() async throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!

    var components = DateComponents()
    components.year = 2025
    components.month = 6
    components.day = 15
    components.hour = 9
    components.minute = 0
    let morningDate = calendar.date(from: components)!

    components.hour = 14
    components.minute = 30
    let afternoonDate = calendar.date(from: components)!

    components.hour = 23
    components.minute = 59
    let eveningDate = calendar.date(from: components)!

    let normalizedMorning = morningDate.normalized(calendar: calendar)
    let normalizedAfternoon = afternoonDate.normalized(calendar: calendar)
    let normalizedEvening = eveningDate.normalized(calendar: calendar)

    // All should normalize to the same date/time (noon on the same day)
    #expect(normalizedMorning == normalizedAfternoon)
    #expect(normalizedAfternoon == normalizedEvening)
  }
}
