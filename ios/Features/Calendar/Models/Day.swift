import Foundation

/// Represents a calendar day (local calendar/timezone) and its events.
public struct Day: Identifiable {
  public typealias ID = Date
  public var date: Date  // Expected to be start of day by callers

  public init(date: Date) {
    // Assume `date` is already normalized by the caller's calendar context
    self.date = date
  }

  public var id: ID { date }

  public var year: Int { Calendar.current.component(.year, from: date) }
  public var month: Int { Calendar.current.component(.month, from: date) }
  public var day: Int { Calendar.current.component(.day, from: date) }
}

extension Day {
  public static func startOfDay(for date: Date, calendar: Calendar = .current) -> Date {
    calendar.startOfDay(for: date)
  }

  /// Returns true if the given entry overlaps this day at all.
  public func contains(_ entry: CalendarEntry, calendar: Calendar = .current) -> Bool {
    let dayStart = date
    guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
      return false
    }
    // Overlap if entry starts before dayEnd and ends after dayStart
    return entry.startDate < dayEnd && entry.endDate > dayStart
  }
}
