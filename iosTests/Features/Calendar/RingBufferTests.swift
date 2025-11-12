import Foundation
import Testing

@testable import ios

struct RingBufferTests {

    @Test func init_validSizes_createsBuffer() {
        let buffer3 = RingBuffer(anchor: 0, size: 3) { $0 }
        #expect(buffer3.centerOffset == 0)

        let buffer5 = RingBuffer(anchor: 10, size: 5) { $0 }
        #expect(buffer5.centerOffset == 0)

        let buffer7 = RingBuffer(anchor: "test", size: 7) { "\($0)" }
        #expect(buffer7.centerOffset == 0)
    }

    @Test func item_atIndex_returnsCorrectValue() {
        let buffer = RingBuffer(anchor: 100, size: 3) { offset in
            offset + 100
        }

        // For size 3, middle is index 1
        // Index 0: centerOffset (0) + (0 - 1) = -1 -> 99
        // Index 1: centerOffset (0) + (1 - 1) = 0 -> 100
        // Index 2: centerOffset (0) + (2 - 1) = 1 -> 101

        #expect(buffer.item(at: 0) == 99)
        #expect(buffer.item(at: 1) == 100)
        #expect(buffer.item(at: 2) == 101)
    }

    @Test func item_atIndex_size5_returnsCorrectValues() {
        let buffer = RingBuffer(anchor: 0, size: 5) { offset in
            offset * 10
        }

        // For size 5, middle is index 2
        // Index 0: 0 + (0 - 2) = -2 -> -20
        // Index 1: 0 + (1 - 2) = -1 -> -10
        // Index 2: 0 + (2 - 2) = 0 -> 0
        // Index 3: 0 + (3 - 2) = 1 -> 10
        // Index 4: 0 + (4 - 2) = 2 -> 20

        #expect(buffer.item(at: 0) == -20)
        #expect(buffer.item(at: 1) == -10)
        #expect(buffer.item(at: 2) == 0)
        #expect(buffer.item(at: 3) == 10)
        #expect(buffer.item(at: 4) == 20)
    }

    @Test func move_forward_updatesCenterOffset() {
        let buffer = RingBuffer(anchor: 0, size: 3) { offset in
            offset
        }

        #expect(buffer.centerOffset == 0)
        #expect(buffer.item(at: 1) == 0)

        buffer.move(by: 1)

        #expect(buffer.centerOffset == 1)
        #expect(buffer.item(at: 1) == 1)
        #expect(buffer.item(at: 0) == 0)
        #expect(buffer.item(at: 2) == 2)
    }

    @Test func move_backward_updatesCenterOffset() {
        let buffer = RingBuffer(anchor: 0, size: 3) { offset in
            offset
        }

        #expect(buffer.centerOffset == 0)

        buffer.move(by: -1)

        #expect(buffer.centerOffset == -1)
        #expect(buffer.item(at: 1) == -1)
        #expect(buffer.item(at: 0) == -2)
        #expect(buffer.item(at: 2) == 0)
    }

    @Test func move_byZero_isNoOp() {
        let buffer = RingBuffer(anchor: 0, size: 3) { offset in
            offset
        }

        let initialOffset = buffer.centerOffset
        buffer.move(by: 0)
        #expect(buffer.centerOffset == initialOffset)
    }

    @Test func move_multipleTimes_accumulatesCorrectly() {
        let buffer = RingBuffer(anchor: 0, size: 3) { offset in
            offset
        }

        buffer.move(by: 3)
        #expect(buffer.centerOffset == 3)
        #expect(buffer.item(at: 1) == 3)

        buffer.move(by: -5)
        #expect(buffer.centerOffset == -2)
        #expect(buffer.item(at: 1) == -2)

        buffer.move(by: 10)
        #expect(buffer.centerOffset == 8)
        #expect(buffer.item(at: 1) == 8)
    }

    @Test func item_withCustomCalculation_usesClosure() {
        let buffer = RingBuffer(anchor: "base", size: 3) { offset in
            "item_\(offset)"
        }

        #expect(buffer.item(at: 0) == "item_-1")
        #expect(buffer.item(at: 1) == "item_0")
        #expect(buffer.item(at: 2) == "item_1")

        buffer.move(by: 5)

        #expect(buffer.item(at: 0) == "item_4")
        #expect(buffer.item(at: 1) == "item_5")
        #expect(buffer.item(at: 2) == "item_6")
    }

    @Test func item_afterMove_preservesRelativePositions() {
        let buffer = RingBuffer(anchor: 0, size: 3) { offset in
            offset
        }

        // Initial state: [-1, 0, 1]
        #expect(buffer.item(at: 0) == -1)
        #expect(buffer.item(at: 1) == 0)
        #expect(buffer.item(at: 2) == 1)

        buffer.move(by: 1)
        // After move(1): [0, 1, 2]
        #expect(buffer.item(at: 0) == 0)
        #expect(buffer.item(at: 1) == 1)
        #expect(buffer.item(at: 2) == 2)

        buffer.move(by: 1)
        // After move(1) again: [1, 2, 3]
        #expect(buffer.item(at: 0) == 1)
        #expect(buffer.item(at: 1) == 2)
        #expect(buffer.item(at: 2) == 3)
    }

    @Test func item_withNegativeOffsets_handlesCorrectly() {
        let buffer = RingBuffer(anchor: 0, size: 3) { offset in
            offset
        }

        buffer.move(by: -10)

        #expect(buffer.centerOffset == -10)
        #expect(buffer.item(at: 0) == -11)
        #expect(buffer.item(at: 1) == -10)
        #expect(buffer.item(at: 2) == -9)
    }

    @Test func item_size7_withMultipleMoves_maintainsCorrectWindow() {
        let buffer = RingBuffer(anchor: 0, size: 7) { offset in
            offset
        }

        // Initial: [-3, -2, -1, 0, 1, 2, 3]
        #expect(buffer.item(at: 3) == 0)  // center

        buffer.move(by: 5)
        // After move(5): [2, 3, 4, 5, 6, 7, 8]
        #expect(buffer.item(at: 3) == 5)  // center
        #expect(buffer.item(at: 0) == 2)
        #expect(buffer.item(at: 6) == 8)

        buffer.move(by: -3)
        // After move(-3): [-1, 0, 1, 2, 3, 4, 5]
        #expect(buffer.item(at: 3) == 2)  // center
        #expect(buffer.item(at: 0) == -1)
        #expect(buffer.item(at: 6) == 5)
    }
}
