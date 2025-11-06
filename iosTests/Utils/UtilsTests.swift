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
}
