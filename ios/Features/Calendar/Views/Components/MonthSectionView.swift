import SwiftUI

struct MonthSectionView: View {
  let month: Month
  let index: Int
  let totalCount: Int
  let isLoadingMore: Bool
  var onNearEndAppear: (() -> Void)?
  var onEventSelected: ((CalendarEntry) -> Void)? = nil

  var body: some View {
    Section(header: Text(CalendarFormatters.monthHeader.string(from: month.firstDay))) {
      if month.days.isEmpty {
        Text("No days in this month")
          .foregroundStyle(.secondary)
      } else {
        ForEach(month.days) { day in
          DayEventsView(day: day, onEventSelected: onEventSelected)
        }
      }
      if shouldPrefetch {
        HStack {
          Spacer()
          if isLoadingMore { ProgressView().padding(.vertical, 8) }
          Spacer()
        }
        .onAppear { onNearEndAppear?() }
      }
    }
  }

  private var shouldPrefetch: Bool { index >= max(0, totalCount - 2) }
}
