import Observation
import SwiftUI
struct CalendarView: View {
  let startDay: Day
  let endDay: Day
  var initialDay: Day? = nil
  var onDayChanged: ((Day) -> Void)? = nil

  var body: some View {
    CalendarBody(startDay: startDay, endDay: endDay, initialDay: initialDay, onDayChanged: onDayChanged)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

#Preview {
  let cal = Calendar.current
  let today = Day(Date(), calendar: cal)
  let start = today.adding(-7)
  let end = today.adding(7)
  return CalendarView(startDay: start, endDay: end, initialDay: today)
}
 
private struct CalendarBody: View {
  let startDay: Day
  let endDay: Day
  var initialDay: Day? = nil
  var onDayChanged: ((Day) -> Void)? = nil

  @State private var selectedDay: Day?

  var body: some View {
    VStack(spacing: 12) {
      let headerText = selectedDay.map { CalendarFormatters.dayFull.string(from: $0.date) } ?? ""
      Text(headerText.isEmpty ? " " : headerText)
        .font(.title2.weight(.semibold))
        .multilineTextAlignment(.center)
        .contentTransition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: headerText)
      DayPagerView(start: startDay, end: endDay, initial: initialDay, onDayChanged: { day in
        selectedDay = day
        onDayChanged?(day)
      }) { day in
        DayTimelineView(day: day)
          .padding(16)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .padding(.top, 16)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
