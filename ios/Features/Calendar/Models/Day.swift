import Foundation

// MARK: - Calendar Helpers (device preferences: locale + timezone)

extension Calendar {
    /// Start of the week containing `date`, according to this calendar's locale/timezone.
    func startOfWeek(containing date: Date) -> Date {
        // Uses ISO-compatible components that respect firstWeekday/locale.
        let comps = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: comps)!
    }

    /// Midnight (start of local day) — wrapper to emphasize semantics.
    func startOfLocalDay(for date: Date) -> Date {
        startOfDay(for: date)
    }
}

// MARK: - Day

public struct Day: Hashable, Comparable, Identifiable {
    /// Calendar captured at creation time (device preferences at that moment).
    public let calendar: Calendar
    /// Canonical anchor inside the day (midnight in `calendar`'s timezone).
    public let date: Date

    public init(_ date: Date, calendar: Calendar = .current) {
        self.calendar = calendar
        self.date = calendar.startOfLocalDay(for: date)
    }

    // Identity & ordering
    public var id: Date { date }
    public static func < (lhs: Day, rhs: Day) -> Bool { lhs.date < rhs.date }

    // Boundaries in absolute time (Date is an instant; timezone applied via `calendar`)
    public var start: Date { date }
    public var end: Date { calendar.date(byAdding: .day, value: 1, to: start)! }
    public var interval: DateInterval { DateInterval(start: start, end: end) }

    // Navigation
    public func adding(_ days: Int) -> Day {
        Day(calendar.date(byAdding: .day, value: days, to: start)!, calendar: calendar)
    }
    public var next: Day { adding(1) }
    public var prev: Day { adding(-1) }

    // MARK: Event helpers (events store absolute UTC instants)

    /// True if the UTC instant falls inside this local day.
    public func contains(instantUTC: Date) -> Bool {
        (start ..< end).contains(instantUTC)
    }

    /// True if any portion of the UTC event overlaps this local day.
    /// Uses half-open intervals so an event ending exactly at `end` belongs to the next day.
    public func overlaps(eventStartUTC: Date, eventEndUTC: Date) -> Bool {
        guard eventStartUTC < eventEndUTC else {
            // Treat zero-length as an instant (e.g., reminder)
            return contains(instantUTC: eventStartUTC)
        }
        return DateInterval(start: eventStartUTC, end: eventEndUTC)
            .intersects(interval)
    }

    /// Fraction (0...1) of the event duration that lies within this local day.
    public func overlapFraction(eventStartUTC: Date, eventEndUTC: Date) -> Double {
        guard eventStartUTC < eventEndUTC else { return contains(instantUTC: eventStartUTC) ? 0 : 0 }
        let event = DateInterval(start: eventStartUTC, end: eventEndUTC)
        if let clipped = event.intersection(with: interval) {
            return clipped.duration / event.duration
        }
        return 0
    }
}

// MARK: - Convenience: bucketing an instant to a Day

public extension Day {
    /// Bucket any absolute instant into the user's local day using the given calendar.
    static func bucket(instantUTC: Date, calendar: Calendar = .current) -> Day {
        Day(instantUTC, calendar: calendar)
    }
}
