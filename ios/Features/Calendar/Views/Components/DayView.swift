import SwiftUI
struct DayView: View {
  let day: Day

  var body: some View {
    VStack(spacing: 12) {
      Text(CalendarFormatters.dayFull.string(from: day.date))
        .font(.title2.weight(.semibold))
        .multilineTextAlignment(.center)
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.secondary.opacity(0.12))
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .overlay(
          Text("No events")
            .foregroundStyle(.secondary)
        )

      Spacer(minLength: 0)
    }
    .padding(16)
  }
}

#Preview {
  let today = Day(Date())
  return DayView(day: today)
    .previewLayout(.sizeThatFits)
}
