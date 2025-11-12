//
//  RingBuffer.swift
//  ios
//
//  Created by Connor Black on 13/10/2025.
//

/// A ring buffer that maintains a sliding window of items around a center offset.
///
/// The buffer uses a closure to calculate items on-demand based on their logical offset
/// from an anchor value. This allows for efficient infinite scrolling without storing
/// all possible items in memory.
///
/// Example:
/// ```swift
/// let buffer = RingBuffer(anchor: 0, size: 3) { offset in
///   offset * 10
/// }
/// // buffer.item(at: 0) == -10
/// // buffer.item(at: 1) == 0  (center)
/// // buffer.item(at: 2) == 10
/// ```
final class RingBuffer<T> {
  private let anchor: T
  private let size: Int  // e.g. 3 for prev / current / next
  private let calculateItem: (Int) -> T

  /// Logical offset for the *center* of the ring, relative to the anchor.
  /// For your calendar this is "how many days from the anchor is the current day?"
  private(set) var centerOffset: Int = 0

  init(
    anchor: T,
    size: Int,
    calculateItem: @escaping (Int) -> T
  ) {
    precondition(size >= 3 && size % 2 == 1, "Size should be odd and >= 3")
    self.anchor = anchor
    self.size = size
    self.calculateItem = calculateItem
  }

  /// Item for a given index in the ring [0..<size].
  /// index == middle → current item
  func item(at index: Int) -> T {
    let middle = size / 2
    let offsetFromCenter = index - middle  // -1, 0, +1 for size 3
    let logicalOffset = centerOffset + offsetFromCenter
    return calculateItem(logicalOffset)
  }

  /// Move the "window" forward/backward.
  func move(by delta: Int) {
    guard delta != 0 else { return }
    centerOffset += delta
  }
}

