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
      // Move to the desired starting offset
      if anchorOffset != 0 {
        offsetBuffer.move(by: anchorOffset)
      }
    }

    /// Updates the ring buffer when scrolling to a new page
    // @MainActor
    public func handlePageChange(newIndex: Int, oldIndex: Int) {
      guard newIndex != oldIndex else { return }

      let clampedIndex = max(Self.minIndex, min(Self.maxIndex, newIndex))

      if clampedIndex == Self.minIndex {
        // Scrolled to previous page - shift buffer backward
        offsetBuffer.move(by: -1)
        // Reset to center after shift
        self.currentPageIndex = Self.centerIndex
      } else if clampedIndex == Self.maxIndex {
        // Scrolled to next page - shift buffer forward
        offsetBuffer.move(by: 1)
        // Reset to center after shift
        self.currentPageIndex = Self.centerIndex
      } else {
        currentPageIndex = newIndex
      }
    }
  }
}
