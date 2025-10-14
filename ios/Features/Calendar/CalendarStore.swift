import Foundation
import Observation

public enum CalendarError: Error, LocalizedError {
    case invalidDateRange
    case entryNotFound

    public var errorDescription: String? {
        switch self {
        case .invalidDateRange:
            return "End date must be after start date."
        case .entryNotFound:
            return "The requested calendar entry was not found."
        }
    }
}

@Observable
@MainActor
public final class CalendarStore {
    public private(set) var entries: [CalendarEntry] = []

    public init(entries: [CalendarEntry] = []) {
        self.entries = entries.sorted(by: { $0.startDate < $1.startDate })
    }

    // MARK: - CRUD

    @discardableResult
    public func addEntry(
        title: String,
        description: String? = nil,
        startDate: Date,
        endDate: Date
    ) async throws(CalendarError) -> CalendarEntry {
        guard endDate > startDate else { throw CalendarError.invalidDateRange }
        let new = CalendarEntry(title: title, eventDescription: description, startDate: startDate, endDate: endDate)
        entries.append(new)
        entries.sort(by: { $0.startDate < $1.startDate })
        return new
    }

    public func removeEntry(id: CalendarEntry.ID) async throws(CalendarError) {
        guard let idx = entries.firstIndex(where: { $0.id == id }) else {
            throw CalendarError.entryNotFound
        }
        entries.remove(at: idx)
    }

    public func updateEntry(_ updated: CalendarEntry) async throws(CalendarError) {
        guard let idx = entries.firstIndex(where: { $0.id == updated.id }) else {
            throw CalendarError.entryNotFound
        }
        entries[idx] = updated
        entries.sort(by: { $0.startDate < $1.startDate })
    }

    // MARK: - Query

    /// Entries that overlap the given date (local day)
    public func entries(on date: Date, calendar: Calendar = .current) async -> [CalendarEntry] {
        let start = calendar.startOfDay(for: date)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return [] }
        return entries.filter { $0.startDate < end && $0.endDate > start }
    }

    /// Returns `count` days starting from `startDate` (default: today), each with its overlapping events.
    public func days(from startDate: Date = Date(), count: Int, calendar: Calendar = .current) async -> [Day] {
        guard count > 0 else { return [] }
        var result: [Day] = []
        var current = calendar.startOfDay(for: startDate)
        for _ in 0..<count {
            let dayEvents = await entries(on: current, calendar: calendar)
            result.append(Day(date: current, events: dayEvents))
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
        }
        return result
    }

    /// Returns `count` months starting from the month containing `startDate` (default: current month).
    /// Each month contains its days and the overlapping events.
    public func months(from startDate: Date = Date(), count: Int, calendar: Calendar = .current) async -> [Month] {
        guard count > 0 else { return [] }
        var result: [Month] = []
        let today = calendar.startOfDay(for: startDate)
        var monthStart = Month.startOfMonth(for: startDate, calendar: calendar)

        for _ in 0..<count {
            var days: [Day] = []
            // Full range of days within the iterated month
            guard let range = calendar.range(of: .day, in: .month, for: monthStart) else {
                result.append(Month(firstDay: monthStart, days: []))
                monthStart = Month.nextMonthStart(after: monthStart, calendar: calendar)
                continue
            }

            // If iterating the current month (the one containing `today`), start from today's day; otherwise from 1
            let iterYear = calendar.component(.year, from: monthStart)
            let iterMonth = calendar.component(.month, from: monthStart)
            let todayYear = calendar.component(.year, from: today)
            let todayMonth = calendar.component(.month, from: today)
            let startDay = (iterYear == todayYear && iterMonth == todayMonth)
                ? max(range.lowerBound, calendar.component(.day, from: today))
                : range.lowerBound

            for day in startDay...range.upperBound {
                if let date = calendar.date(bySetting: .day, value: day, of: monthStart) {
                    let dayStart = calendar.startOfDay(for: date)
                    // Skip any day before 'today' just in case
                    if dayStart < today { continue }
                    let evts = await entries(on: dayStart, calendar: calendar)
                    days.append(Day(date: dayStart, events: evts))
                }
            }

            result.append(Month(firstDay: monthStart, days: days))
            monthStart = Month.nextMonthStart(after: monthStart, calendar: calendar)
        }
        return result
    }
}
