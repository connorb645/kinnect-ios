import SwiftUI
struct DayTimelineView: View {
  let day: Day

  private let rowHeight: CGFloat = 56
  private let leftGutterWidth: CGFloat = 56

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.secondary.opacity(0.12))
      ScrollView(.vertical, showsIndicators: false) {
        LazyVStack(spacing: 0) {
          ForEach(0..<24, id: \.self) { hour in
            hourRow(hour: hour)
          }
        }
        .padding(.vertical, 8)
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }

  @ViewBuilder
  private func hourRow(hour: Int) -> some View {
    HStack(alignment: .center, spacing: 8) {
      let gutter = hour == 0 ? 0 : leftGutterWidth
      Text(hour == 0 ? "" : hourLabel(for: hour))
        .font(.caption)
        .foregroundStyle(.secondary)
        .frame(width: gutter, alignment: .trailing)
        .frame(height: rowHeight, alignment: .center)
      ZStack(alignment: .center) {
        if hour > 0 {
          Rectangle()
            .fill(Color.secondary.opacity(0.15))
            .frame(height: 1 / UIScreen.main.scale)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        Rectangle()
          .fill(Color.clear)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      }
      .frame(height: rowHeight)
    }
  }

  private func hourLabel(for hour: Int) -> String {
    let cal = day.calendar
    var comps = cal.dateComponents([.year, .month, .day], from: day.date)
    comps.hour = hour
    comps.minute = 0
    let date = cal.date(from: comps) ?? day.date
    return CalendarFormatters.timeShort.string(from: date)
  }
}

#Preview {
  DayTimelineView(day: Day(Date()))
    .padding(16)
}
