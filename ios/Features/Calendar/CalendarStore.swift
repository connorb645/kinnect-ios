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

    public init(entries: [CalendarEntry] = CalendarStore.mockEntries()) {
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

    // MARK: - Mock Data

    public static func mockEntries(reference: Date = Date(), calendar: Calendar = .current) -> [CalendarEntry] {
        let today = calendar.startOfDay(for: reference)

        func makeEvent(
            _ title: String,
            description: String? = nil,
            dayOffset: Int,
            hour: Int,
            minute: Int = 0,
            durationMinutes: Int
        ) -> CalendarEntry? {
            guard
                let day = calendar.date(byAdding: .day, value: dayOffset, to: today),
                let start = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day),
                let end = calendar.date(byAdding: .minute, value: durationMinutes, to: start)
            else { return nil }

            return CalendarEntry(
                title: title,
                eventDescription: description,
                startDate: start,
                endDate: end
            )
        }

        let entries: [CalendarEntry?] = [
            makeEvent(
                "Daily Standup",
                description: "Quick sync with the mobile team.",
                dayOffset: 0,
                hour: 9,
                durationMinutes: 30
            ),
            makeEvent(
                "Product Design Review",
                description: "Review latest Kinnect designs with design org.",
                dayOffset: 0,
                hour: 11,
                durationMinutes: 75
            ),
            makeEvent(
                "Client Check-In",
                description: "Weekly status update with Alpine Bank.",
                dayOffset: 1,
                hour: 14,
                minute: 30,
                durationMinutes: 45
            ),
            makeEvent(
                "Growth Strategy Workshop",
                description: "Cross-functional roadmap planning for Q3.",
                dayOffset: 2,
                hour: 10,
                durationMinutes: 120
            ),
            makeEvent(
                "Hack Day",
                description: "Heads-down experimentation time for the whole team.",
                dayOffset: 3,
                hour: 9,
                durationMinutes: 8 * 60
            ),
            makeEvent(
                "Team Social",
                description: "Dinner with the NYC office.",
                dayOffset: 5,
                hour: 18,
                durationMinutes: 150
            ),
            makeEvent(
                "Kinnect Launch Prep",
                description: "Finalize assets ahead of Thursday's release.",
                dayOffset: 6,
                hour: 16,
                durationMinutes: 90
            ),
            makeEvent(
                "Wellness Day",
                description: "Company-wide day off to recharge.",
                dayOffset: 7,
                hour: 0,
                durationMinutes: 24 * 60
            )
        ]

        return entries.compactMap { $0 }.sorted(by: { $0.startDate < $1.startDate })
    }
}
