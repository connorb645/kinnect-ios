import SwiftUI
struct DayPagerView<Content: View>: View {
  private let days: [Day]
  private let onDayChanged: ((Day) -> Void)?
  private let content: (Day) -> Content

  @State private var selectedDay: Day

  init(
    start: Day,
    end: Day,
    initial: Day? = nil,
    onDayChanged: ((Day) -> Void)? = nil,
    @ViewBuilder content: @escaping (Day) -> Content = { DayView(day: $0) }
  ) {
    let normalized = DayPagerView.daysInRange(start: start, end: end)
    self.days = normalized
    let initialClamped = DayPagerView.clamp(initial ?? start, to: normalized) ?? normalized.first!
    self._selectedDay = State(initialValue: initialClamped)
    self.onDayChanged = onDayChanged
    self.content = content
  }

  var body: some View {
    VStack(spacing: 0) {
      TabView(selection: $selectedDay) {
        ForEach(days) { day in
          content(day)
            .tag(day)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
      .onAppear {
        onDayChanged?(selectedDay)
      }
      .onChange(of: selectedDay) { _, newValue in
        onDayChanged?(newValue)
      }
    }
  }

  static func daysInRange(start: Day, end: Day) -> [Day] {
    let lower = min(start, end)
    let upper = max(start, end)
    var out: [Day] = []
    var cur = lower
    out.append(cur)
    while cur < upper {
      cur = cur.next
      out.append(cur)
    }
    return out
  }
  static func clamp(_ candidate: Day, to days: [Day]) -> Day? {
    guard let first = days.first, let last = days.last else { return nil }
    if candidate < first { return first }
    if candidate > last { return last }
    return candidate
  }
}

#Preview {
  let cal = Calendar.current
  let today = Day(Date(), calendar: cal)
  let start = today.adding(-3)
  let end = today.adding(3)
  return DayPagerView(start: start, end: end, initial: today) { day in
    DayView(day: day)
  }
}
