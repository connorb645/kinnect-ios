import Foundation

/// Represents a calendar month and its days.
public struct Month: Identifiable {
    public typealias ID = Date // First day of month at startOfDay

    public var firstDay: Date
    public var days: [Day]

    public init(firstDay: Date, days: [Day]) {
        // Assume `firstDay` is already normalized to the start of the month
        self.firstDay = firstDay
        self.days = days
    }

    public var id: ID { firstDay }

    public var year: Int { Calendar.current.component(.year, from: firstDay) }
    public var month: Int { Calendar.current.component(.month, from: firstDay) }
}

public extension Month {
    static func startOfMonth(for date: Date, calendar: Calendar = .current) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps).map { calendar.startOfDay(for: $0) } ?? calendar.startOfDay(for: date)
    }

    static func nextMonthStart(after date: Date, calendar: Calendar = .current) -> Date {
        let start = startOfMonth(for: date, calendar: calendar)
        return calendar.date(byAdding: DateComponents(month: 1), to: start) ?? start
    }
}
