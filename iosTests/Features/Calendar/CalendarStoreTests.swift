import Foundation
import Testing

@testable import ios

private let gmt = TimeZone(secondsFromGMT: 0)!
private var gregorianGMT: Calendar {
  var c = Calendar(identifier: .gregorian)
  c.timeZone = gmt
  return c
}

private func makeDate(_ y: Int, _ m: Int, _ d: Int, _ h: Int = 0, _ min: Int = 0) -> Date {
  var comps = DateComponents()
  comps.year = y
  comps.month = m
  comps.day = d
  comps.hour = h
  comps.minute = min
  var cal = gregorianGMT
  return cal.date(from: comps)!
}

@MainActor
struct CalendarStoreTests {

  @Test func addEntry_sorts_and_returns() async throws {
    let store = CalendarStore(entries: [])
    let start1 = makeDate(2025, 1, 1, 9, 0)
    let end1 = makeDate(2025, 1, 1, 10, 0)
    let start0 = makeDate(2024, 12, 31, 22, 0)
    let end0 = makeDate(2024, 12, 31, 23, 0)

    let e1 = try await store.addEntry(title: "Late", startDate: start1, endDate: end1)
    let e0 = try await store.addEntry(title: "Early", startDate: start0, endDate: end0)

    #expect(store.entries.count == 2)
    #expect(store.entries.first?.id == e0.id)
    #expect(store.entries.last?.id == e1.id)
    #expect(e1.title == "Late")
  }

  @Test func addEntry_invalid_range_throws() async throws {
    let store = CalendarStore(entries: [])
    let start = makeDate(2025, 1, 1, 10, 0)
    let end = makeDate(2025, 1, 1, 10, 0)
    await #expect(throws: CalendarError.invalidDateRange) {
      _ = try await store.addEntry(title: "Bad", startDate: start, endDate: end)
    }
  }

  @Test func updateEntry_updates_and_resorts() async throws {
    let store = CalendarStore(entries: [])
    let aStart = makeDate(2025, 1, 2, 12, 0)
    let aEnd = makeDate(2025, 1, 2, 13, 0)
    let bStart = makeDate(2025, 1, 3, 12, 0)
    let bEnd = makeDate(2025, 1, 3, 13, 0)

    let a = try await store.addEntry(title: "A", startDate: aStart, endDate: aEnd)
    _ = try await store.addEntry(title: "B", startDate: bStart, endDate: bEnd)

    var updatedA = a
    updatedA.title = "A2"
    updatedA.startDate = makeDate(2025, 1, 4, 9, 0)  // move after B
    updatedA.endDate = makeDate(2025, 1, 4, 10, 0)
    try await store.updateEntry(updatedA)

    #expect(store.entries.count == 2)
    #expect(store.entries.first?.title == "B")
    #expect(store.entries.last?.title == "A2")

    await #expect(throws: CalendarError.entryNotFound) {
      let ghost = CalendarEntry(
        id: UUID(),
        title: "Ghost",
        startDate: makeDate(2025, 1, 5, 9, 0),
        endDate: makeDate(2025, 1, 5, 10, 0)
      )
      try await store.updateEntry(ghost)
    }
  }

  @Test func updateEntry_invalid_range_throws() async throws {
    let store = CalendarStore()
    let start = makeDate(2025, 6, 1, 8, 0)
    let end = makeDate(2025, 6, 1, 9, 0)
    let entry = try await store.addEntry(title: "Valid", startDate: start, endDate: end)

    var updated = entry
    updated.endDate = start  // collapse range

    await #expect(throws: CalendarError.invalidDateRange) {
      try await store.updateEntry(updated)
    }
  }

  @Test func removeEntry_removes_and_throws_when_missing() async throws {
    let store = CalendarStore(entries: [])
    let start = makeDate(2025, 2, 1, 9, 0)
    let end = makeDate(2025, 2, 1, 10, 0)
    let e = try await store.addEntry(title: "ToRemove", startDate: start, endDate: end)
    try await store.removeEntry(id: e.id)
    #expect(store.entries.isEmpty)

    await #expect(throws: CalendarError.entryNotFound) {
      try await store.removeEntry(id: e.id)
    }
  }

  @Test func entries_on_day_overlap_boundaries() async throws {
    let cal = gregorianGMT
    let store = CalendarStore(entries: [])
    let day = makeDate(2025, 3, 10)
    let dayStart = cal.startOfDay(for: day)
    let nextDayStart = cal.date(byAdding: .day, value: 1, to: dayStart)!

    // Ends exactly at day start -> exclude
    _ = try await store.addEntry(
      title: "E0", startDate: makeDate(2025, 3, 9, 23, 0), endDate: dayStart)
    // Starts exactly at next day start -> exclude
    _ = try await store.addEntry(
      title: "E1", startDate: nextDayStart,
      endDate: cal.date(byAdding: .hour, value: 1, to: nextDayStart)!)
    // Fully within -> include
    _ = try await store.addEntry(
      title: "E2", startDate: makeDate(2025, 3, 10, 9, 0), endDate: makeDate(2025, 3, 10, 10, 0))
    // Spans entire day -> include
    _ = try await store.addEntry(
      title: "E3", startDate: makeDate(2025, 3, 9, 12, 0), endDate: makeDate(2025, 3, 11, 12, 0))

    let results = await store.entries(on: day, calendar: cal).map { $0.title }.sorted()
    #expect(results == ["E2", "E3"])  // E0/E1 excluded by boundary rules
  }
}
