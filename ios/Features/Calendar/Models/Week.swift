import Foundation

// MARK: - Week

public struct Week: Hashable, Comparable {
    public let calendar: Calendar
    /// Canonical representation: start-of-week (per `calendar`)
    public let start: Date

    public init(containing date: Date, calendar: Calendar = .current) {
        self.calendar = calendar
        self.start = calendar.startOfWeek(containing: date)
    }

    /// Alternative: construct from known week anchor (must already be a start-of-week).
    public init(startOfWeek: Date, calendar: Calendar = .current) {
        self.calendar = calendar
        self.start = calendar.startOfWeek(containing: startOfWeek)
    }

    public var end: Date { calendar.date(byAdding: .weekOfYear, value: 1, to: start)! }
    public var interval: DateInterval { DateInterval(start: start, end: end) }

    /// Lazily computed 7 local days making up this week.
    public var days: [Day] {
        (0..<7).map { offset in
            let d = calendar.date(byAdding: .day, value: offset, to: start)!
            return Day(d, calendar: calendar)
        }
    }

    // Navigation
    public func adding(_ weeks: Int) -> Week {
        Week(containing: calendar.date(byAdding: .weekOfYear, value: weeks, to: start)!, calendar: calendar)
    }
    public var next: Week { adding(1) }
    public var prev: Week { adding(-1) }

    // Ordering
    public static func < (lhs: Week, rhs: Week) -> Bool { lhs.start < rhs.start }
}

