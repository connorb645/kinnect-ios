import Observation
import SwiftUI

/// Reusable, presentation-only calendar view that renders
/// a horizontal month scroller and an event-centric list
/// filtered to the selected month. Sheets/toolbars are owned
/// by the parent screen.
struct CalendarView: View {
  @Bindable var store: CalendarStore
  let months: [Month]
  @Binding var selectedMonthStart: Date?
  var onReload: (() -> Void)? = nil
  var onAddEventForDay: ((Date) -> Void)? = nil

  @State private var editingEntry: CalendarEntry?
  @Environment(AppTheme.self) private var theme
  @Environment(\.colorScheme) private var colorScheme
  private var palette: AppTheme.Palette { theme.palette(for: colorScheme) }

  var body: some View {
    let selectedMonth = months.first(where: { $0.start == selectedMonthStart }) ?? months.first
    let allDays: [Day] = selectedMonth?.days ?? []

    return List {
      monthScroller

      ForEach(allDays) { day in
        let events = store.entries.filter { ev in
          day.overlaps(eventStartUTC: ev.startDate, eventEndUTC: ev.endDate)
        }
        Section(header: dayHeader(day)) {
          if events.isEmpty {
            EmptyView()
          } else {
            ForEach(events) { event in
              EventRowView(event: event)
                .swipeActions(edge: .trailing) {
                  Button {
                    editingEntry = event
                  } label: {
                    Label("Edit", systemImage: "square.and.pencil")
                  }
                  .tint(.blue)
                }
                .listRowSeparator(.hidden)
            }
          }
        }
      }
    }
    .listStyle(.plain)
    .sheet(item: $editingEntry) { entry in
      EventEntrySheetView(
        mode: .edit(entry),
        onSave: { title, desc, start, end in
          let updated = CalendarEntry(
            id: entry.id,
            title: title,
            eventDescription: desc,
            startDate: start,
            endDate: end
          )
          try await store.updateEntry(updated)
          onReload?()
          editingEntry = nil
        },
        onCancel: { editingEntry = nil }
      )
      .presentationDetents([.height(520), .large])
      .presentationDragIndicator(.visible)
    }
  }

  private func dayHeader(_ day: Day) -> some View {
    HStack(alignment: .center, spacing: 8) {
      Text(CalendarFormatters.dayFull.string(from: day.date))
        .font(.subheadline.weight(.medium))
        .foregroundStyle(palette.secondary)
      Spacer()
      Button {
        onAddEventForDay?(day.date)
      } label: {
        Image(systemName: "plus.circle")
      }
      .buttonStyle(.plain)
      .tint(palette.accent)
    }
  }

  private var monthScroller: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(months, id: \.start) { month in
          let isSelected = month.start == selectedMonthStart
          Button {
            selectedMonthStart = month.start
          } label: {
            Text(CalendarFormatters.monthShortYear.string(from: month.start))
              .font(.subheadline)
              .foregroundStyle(isSelected ? palette.primary : palette.secondary)
              .underline(isSelected)
              .padding(.vertical, 6)
              .padding(.horizontal, 8)
          }
          .buttonStyle(.plain)
          .contentShape(Rectangle())
        }
      }
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
    }
    .listRowInsets(EdgeInsets())
  }
}

#Preview {
  struct Wrapper: View {
    @State var store = CalendarStore()
    @State var months: [Month] = []
    @State var selected: Date? = nil
    var body: some View {
      CalendarView(store: store, months: months, selectedMonthStart: $selected)
    }
  }
  return Wrapper()
}
