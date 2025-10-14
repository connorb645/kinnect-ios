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
    comps.year = y; comps.month = m; comps.day = day; comps.hour = h; comps.minute = min
    return calGMT.date(from: comps)!
}

@MainActor
struct MonthHelpersTests {
    @Test func startOfMonth_normalizes_time_and_is_stable() async throws {
        let cal = calGMT
        let date = d(2025, 1, 18, 15, 30)
        let som = Month.startOfMonth(for: date, calendar: cal)
        var comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: som)
        #expect(comps.year == 2025 && comps.month == 1 && comps.day == 1)
        #expect(comps.hour == 0 && comps.minute == 0)

        // Any other date in same month gives same start
        let som2 = Month.startOfMonth(for: d(2025, 1, 3, 1, 1), calendar: cal)
        #expect(som == som2)
    }

    @Test func nextMonthStart_handles_varied_lengths_and_rollover() async throws {
        let cal = calGMT
        // Jan -> Feb, Feb -> Mar, Dec -> Jan next year
        let jan = Month.startOfMonth(for: d(2025, 1, 15), calendar: cal)
        let feb = Month.nextMonthStart(after: jan, calendar: cal)
        let mar = Month.nextMonthStart(after: feb, calendar: cal)
        #expect(cal.component(.month, from: jan) == 1)
        #expect(cal.component(.month, from: feb) == 2)
        #expect(cal.component(.month, from: mar) == 3)

        let dec = Month.startOfMonth(for: d(2025, 12, 5), calendar: cal)
        let nextJan = Month.nextMonthStart(after: dec, calendar: cal)
        #expect(cal.component(.month, from: dec) == 12)
        #expect(cal.component(.month, from: nextJan) == 1)
        #expect(cal.component(.year, from: nextJan) == 2026)
    }
}
