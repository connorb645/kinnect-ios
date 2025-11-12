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
    private static let minIndex = 0
    private static var maxIndex: Int { bufferSize - 1 }
    private static var centerIndex: Int { bufferSize / 2 }

    // MARK: - State
    public var destination: Destination?
    public var currentPageIndex: Int

    // MARK: - Ring Buffer State
    /// Ring buffer managing offsets: [previous, current, next]
    public let offsetBuffer: RingBuffer<Int>

    /// The anchor offset that the buffer is centered around
    public var anchorOffset: Int {
      offsetBuffer.centerOffset
    }

    public init(anchorOffset: Int = 0) {
      self.destination = nil
      self.currentPageIndex = Self.centerIndex
      self.offsetBuffer = RingBuffer(anchor: anchorOffset, size: Self.bufferSize) { offset in
        offset
      }
      offsetBuffer.move(by: anchorOffset)
    }

    /// Updates the ring buffer when scrolling to a new page
    // @MainActor
    public func handlePageChange(newIndex: Int, oldIndex: Int) {
      guard newIndex != oldIndex else { return }

      let clampedIndex = max(Self.minIndex, min(Self.maxIndex, newIndex))

      // Handle boundary conditions: if we've scrolled to the first or last page,
      // shift the buffer and reset to center. Otherwise, just update the index.
      let isAtMinimum = clampedIndex == Self.minIndex
      let isAtMaximum = clampedIndex == Self.maxIndex

      if isAtMinimum {
        // Scrolled to first page - shift buffer backward
        offsetBuffer.move(by: -1)
        resetToCenter()
      } else if isAtMaximum {
        // Scrolled to last page - shift buffer forward
        offsetBuffer.move(by: 1)
        resetToCenter()
      } else {
        // Scrolled to a middle page - no buffer shift needed
        currentPageIndex = clampedIndex
      }
    }

    private func resetToCenter() {
      currentPageIndex = Self.centerIndex
    }
  }
}
