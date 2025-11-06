import Foundation

// MARK: - Month

public struct Month: Hashable, Comparable {
    public let calendar: Calendar
    public let year: Int
    public let month: Int   // 1...12

    public init(year: Int, month: Int, calendar: Calendar = .current) {
        self.calendar = calendar
        self.year = year
        self.month = month
    }

    public init(containing date: Date, calendar: Calendar = .current) {
        self.calendar = calendar
        let comps = calendar.dateComponents([.year, .month], from: date)
        self.year = comps.year!
        self.month = comps.month!
    }

    public var start: Date { calendar.date(from: DateComponents(year: year, month: month, day: 1))! }
    public var end: Date { calendar.date(byAdding: .month, value: 1, to: start)! }
    public var interval: DateInterval { DateInterval(start: start, end: end) }

    public var numberOfDays: Int {
        calendar.range(of: .day, in: .month, for: start)!.count
    }

    /// Days strictly inside the month.
    public var days: [Day] {
        (0..<numberOfDays).map { i in
            Day(calendar.date(byAdding: .day, value: i, to: start)!, calendar: calendar)
        }
    }

    /// Weeks that *intersect* this month (useful for list-style week sections).
    public var weeks: [Week] {
        var result: [Week] = []
        var w = Week(containing: start, calendar: calendar)
        while w.start < end { result.append(w); w = w.next }
        return result
    }

    /// Weeks padded to a full grid (classic month view). 4–6 rows, 7 days each.
    public var gridWeeks: [[Day]] {
        let firstGridStart = calendar.startOfWeek(containing: start)
        let lastDayInMonth = calendar.date(byAdding: .day, value: -1, to: end)!
        let lastGridStart = calendar.startOfWeek(containing: lastDayInMonth)

        var rows: [[Day]] = []
        var cursor = firstGridStart
        while cursor <= lastGridStart {
            rows.append(Week(containing: cursor, calendar: calendar).days)
            cursor = calendar.date(byAdding: .weekOfYear, value: 1, to: cursor)!
        }
        return rows
    }

    // Navigation
    public func adding(_ months: Int) -> Month {
        let newStart = calendar.date(byAdding: .month, value: months, to: start)!
        return Month(containing: newStart, calendar: calendar)
    }
    public var next: Month { adding(1) }
    public var prev: Month { adding(-1) }

    // Ordering
    public static func < (lhs: Month, rhs: Month) -> Bool { lhs.start < rhs.start }
}
