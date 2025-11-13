import Foundation
import Observation
import SwiftUINavigation

extension CalendarRootScreenView {
  @Observable
  public class ScreenState {
    public static var initial: ScreenState {
      ScreenState()
    }

    // MARK: - Types
    @CasePathable
    public enum Destination {
      public enum SheetDestination {
        case askAI
      }

      case sheet(SheetDestination)
    }

    // MARK: - Constants
    private static let bufferSize = 3
    private let calendar = Calendar.current

    // MARK: - State
    public var destination: Destination?
    public var currentPageIndex: Int

    // MARK: - Ring Buffer State
    /// Ring buffer managing dates: [previous, current, next]
    public let dateBuffer: RingBuffer<Date>

    /// The anchor date that the buffer is centered around
    public var anchorDate: Date {
      dateBuffer.item(at: dateBuffer.centerIndex)
    }

    /// The number of days offset from the anchor date
    public var centerOffset: Int {
      dateBuffer.centerOffset
    }

    public init(anchorDate: Date = Date()) {
      self.destination = nil
      let normalizedAnchor = anchorDate.normalized(toHour: 12, minute: 0, calendar: calendar)
      self.dateBuffer = RingBuffer(anchor: normalizedAnchor, size: Self.bufferSize) {
        [calendar, normalizedAnchor] offset in
        calendar.date(byAdding: .day, value: offset, to: normalizedAnchor) ?? normalizedAnchor
      }
      self.currentPageIndex = dateBuffer.centerIndex
    }

    /// Updates the ring buffer when scrolling to a new page
    @MainActor
    public func handlePageChange(newIndex: Int, oldIndex: Int) {
      guard let delta = dateBuffer.shiftDeltaForIndexChange(from: oldIndex, to: newIndex) else {
        // No shift needed - just update the index
        currentPageIndex = dateBuffer.clampIndex(newIndex)
        return
      }

      // Shift the buffer
      dateBuffer.move(by: delta)

      // After shifting, preserve the visual scroll position
      // The user was at newIndex visually, and after the shift, that position
      // now shows the correct date. We update the logical index to match the
      // visual position, which after a shift is now the center.
      currentPageIndex = dateBuffer.centerIndex
    }
  }
}
