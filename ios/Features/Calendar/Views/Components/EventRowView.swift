import SwiftUI

struct EventRowView: View {
    let event: CalendarEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.title)
                .font(.headline)
            Text("\(CalendarFormatters.timeShort.string(from: event.startDate)) — \(CalendarFormatters.timeShort.string(from: event.endDate))")
                .font(.footnote)
                .foregroundStyle(.secondary)
            if let desc = event.eventDescription, !desc.isEmpty {
                Text(desc)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    EventRowView(event: CalendarEntry(title: "Sample", startDate: .now, endDate: .now.addingTimeInterval(3600)))
        .padding()
}

