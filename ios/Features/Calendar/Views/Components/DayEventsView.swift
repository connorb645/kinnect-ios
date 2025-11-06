import SwiftUI

#if canImport(UIKit)
  import UIKit
#endif

struct DayEventsView: View {
  let day: Day
  let events: [CalendarEntry]
  var onEventSelected: ((CalendarEntry) -> Void)? = nil

  var body: some View {
    if events.isEmpty {
      Text(CalendarFormatters.dayFull.string(from: day.date))
        .foregroundStyle(.secondary)
    } else {
      VStack(alignment: .leading, spacing: 8) {
        Text(CalendarFormatters.dayFull.string(from: day.date))
          .font(.subheadline)
          .foregroundStyle(.secondary)
        ForEach(events) { event in
          EventRowView(event: event)
            .swipeActions(edge: .trailing) {
              Button {
                #if canImport(UIKit)
                  UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                #endif
                onEventSelected?(event)
              } label: {
                Label("Edit", systemImage: "square.and.pencil")
              }
              .tint(.blue)
            }
        }
      }
      .padding(.vertical, 6)
    }
  }
}

#Preview {
  let entry = CalendarEntry(
    title: "Standup", startDate: .now, endDate: .now.addingTimeInterval(1800))
  DayEventsView(day: Day(.now), events: [entry])
    .padding()
}
