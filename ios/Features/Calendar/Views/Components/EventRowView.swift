import SwiftUI

struct EventRowView: View {
    let event: CalendarEntry
    @Environment(AppTheme.self) private var theme
    @Environment(\.colorScheme) private var colorScheme
    private var palette: AppTheme.Palette { theme.palette(for: colorScheme) }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Capsule()
                .fill(palette.accent)
                .frame(width: 3, height: 38)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(palette.primary)
                    .lineLimit(2)

                Text("\(CalendarFormatters.timeShort.string(from: event.startDate)) — \(CalendarFormatters.timeShort.string(from: event.endDate))")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(palette.accent)

                if let desc = event.eventDescription, !desc.isEmpty {
                    Text(desc)
                        .font(.footnote)
                        .foregroundStyle(palette.secondary)
                        .lineLimit(3)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.secondary.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.secondary.opacity(0.12), lineWidth: 1)
        )
        .padding(.vertical, 4)
    }
}

#Preview {
    EventRowView(event: CalendarEntry(title: "Sample", startDate: .now, endDate: .now.addingTimeInterval(3600)))
        .padding()
}
