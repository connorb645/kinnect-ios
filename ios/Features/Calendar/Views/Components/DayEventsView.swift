import SwiftUI

struct DayEventsView: View {
    let day: Day

    var body: some View {
        if day.events.isEmpty {
            Text(CalendarFormatters.dayFull.string(from: day.date))
                .foregroundStyle(.secondary)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text(CalendarFormatters.dayFull.string(from: day.date))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ForEach(day.events) { event in
                    EventRowView(event: event)
                }
            }
            .padding(.vertical, 6)
        }
    }
}

#Preview {
    let entry = CalendarEntry(title: "Standup", startDate: .now, endDate: .now.addingTimeInterval(1800))
    DayEventsView(day: Day(date: .now, events: [entry]))
        .padding()
}

