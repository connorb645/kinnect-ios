//
//  Date+Extensions.swift
//  ios
//
//  Created by Connor Black on 13/10/2025.
//

import Foundation

extension Date {
  /// Normalizes the date to a specific time of day to avoid time drift.
  ///
  /// This is useful when performing day-based calculations to ensure consistent
  /// behavior regardless of the original time component or timezone changes.
  ///
  /// - Parameters:
  ///   - hour: The hour to set (0-23). Defaults to 12 (noon).
  ///   - minute: The minute to set (0-59). Defaults to 0.
  ///   - calendar: The calendar to use for date calculations. Defaults to `.current`.
  /// - Returns: A new date with the same day but normalized to the specified time.
  func normalized(
    toHour hour: Int = 12,
    minute: Int = 0,
    calendar: Calendar = .current
  ) -> Date {
    var components = calendar.dateComponents([.year, .month, .day], from: self)
    components.hour = hour
    components.minute = minute
    components.second = 0
    components.nanosecond = 0
    return calendar.date(from: components) ?? self
  }
}
