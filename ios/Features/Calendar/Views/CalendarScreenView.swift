import Observation
import SwiftUI

struct CalendarScreenView: View {
  @Bindable var store: CalendarStore
  var onAskAI: (() -> Void)? = nil

  @State private var isAskAISheetPresented = false
  @State private var askAIText: String = ""
  @State private var isAddEventSheetPresented = false
  @State private var addPresetStartDate: Date? = nil

  let rangeStart: Day
  let rangeEnd: Day
  let initialDay: Day

  init(store: CalendarStore, onAskAI: (() -> Void)? = nil, startDate: Date? = nil, endDate: Date? = nil, initialDate: Date? = nil, calendar: Calendar = .current) {
    self.store = store
    self.onAskAI = onAskAI
    let today = calendar.startOfDay(for: Date())
    let start = startDate ?? calendar.date(byAdding: .day, value: -3, to: today) ?? today
    let end = endDate ?? calendar.date(byAdding: .day, value: 3, to: today) ?? today
    self.rangeStart = Day(start, calendar: calendar)
    self.rangeEnd = Day(end, calendar: calendar)
    self.initialDay = Day(initialDate ?? today, calendar: calendar)
  }

  var body: some View {
    Group { content }
      .fontDesign(.monospaced)
      .navigationTitle("")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar { toolbarContent }
      .sheet(isPresented: $isAskAISheetPresented) {
        AskAISheetView(text: $askAIText) {
          isAskAISheetPresented = false
        }
        .presentationDetents([.height(420), .height(700)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
      }
      .sheet(isPresented: $isAddEventSheetPresented) {
        EventEntrySheetView(
          mode: .add,
          initialStartDate: addPresetStartDate,
          initialEndDate: addPresetStartDate?.addingTimeInterval(60 * 60),
          onSave: { title, desc, start, end in
            _ = try await store.addEntry(
              title: title, description: desc, startDate: start, endDate: end)
            addPresetStartDate = nil
            isAddEventSheetPresented = false
          },
          onCancel: {
            addPresetStartDate = nil
            isAddEventSheetPresented = false
          }
        )
        .presentationDetents([.height(520), .large])
        .presentationDragIndicator(.visible)
      }
  }

  private func defaultStart(for dayStart: Date) -> Date {
    let cal = Calendar.current
    if let nineAM = cal.date(bySettingHour: 9, minute: 0, second: 0, of: dayStart) {
      return nineAM
    }
    return dayStart
  }

  @ViewBuilder
  private var content: some View {
    CalendarView(startDay: rangeStart, endDay: rangeEnd, initialDay: initialDay)
  }

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .navigationBarTrailing) {
      Menu {
        Menu {
          Button {
            isAddEventSheetPresented = true
          } label: {
            Label("Manual…", systemImage: "square.and.pencil")
          }
        } label: {
          Label("Add Event", systemImage: "calendar.badge.plus")
        }
        Button {
          onAskAI?()
          isAskAISheetPresented = true
        } label: {
          Label("Ask AI", systemImage: "sparkles")
        }
      } label: {
        Image(systemName: "plus")
      }
    }
  }
}

#Preview {
  let store = CalendarStore()
  return NavigationStack { CalendarScreenView(store: store) }
}
