import Observation
import SwiftUI

struct CalendarScreenView: View {
  @Bindable var store: CalendarStore
  var onAskAI: (() -> Void)? = nil

  enum ScreenState {
    case loading
    case empty
    case content(months: [Month])
  }

  @State private var months: [Month] = []
  @State private var isInitialLoading = false
  @State private var isAskAISheetPresented = false
  @State private var askAIText: String = ""
  @State private var isAddEventSheetPresented = false
  @State private var addPresetStartDate: Date? = nil
  @State private var selectedMonthID: Month.ID?

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
            // Reload months to reflect new event and preserve selection
            await reloadMonthsPreservingSelection()
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
      .task { await loadInitialMonths() }
  }

  // MARK: - Loading

  private func loadInitialMonths() async {
    guard months.isEmpty else { return }
    isInitialLoading = true
    months = await store.months(from: .now, count: monthsToLoad)
    selectedMonthID = months.first?.id
    isInitialLoading = false
  }

  private func reloadFromToday() async {
    months = await store.months(from: .now, count: monthsToLoad)
    selectedMonthID = months.first?.id
  }

  private func reloadMonthsPreservingSelection() async {
    let currentSelected = selectedMonthID
    let newMonths = await store.months(from: .now, count: monthsToLoad)
    months = newMonths
    if let selected = currentSelected, newMonths.contains(where: { $0.id == selected }) {
      selectedMonthID = selected
    } else {
      selectedMonthID = newMonths.first?.id
    }
  }

  private var monthsToLoad: Int {
    let cal = Calendar.current
    let start = Month.startOfMonth(for: Date(), calendar: cal)
    let fiftyYearsOut = cal.date(byAdding: .year, value: 50, to: start) ?? start
    let end = Month.startOfMonth(for: fiftyYearsOut, calendar: cal)
    let comps = cal.dateComponents([.month], from: start, to: end)
    // Inclusive of both start and end months
    return max(1, (comps.month ?? 0) + 1)
  }

  private func defaultStart(for dayStart: Date) -> Date {
    let cal = Calendar.current
    if let nineAM = cal.date(bySettingHour: 9, minute: 0, second: 0, of: dayStart) {
      return nineAM
    }
    return dayStart
  }

  // MARK: - View Builders

  @ViewBuilder
  private var content: some View {
    if isInitialLoading && months.isEmpty {
      loadingView
    } else if months.isEmpty {
      emptyState
    } else {
      CalendarView(
        store: store,
        months: months,
        selectedMonthID: $selectedMonthID,
        onReload: { Task { await reloadMonthsPreservingSelection() } },
        onAddEventForDay: { dayStart in
          addPresetStartDate = defaultStart(for: dayStart)
          isAddEventSheetPresented = true
        }
      )
    }
  }

  // content is provided by CalendarView child

  private var loadingView: some View {
    ProgressView()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private var emptyState: some View {
    Text("Your upcoming months will appear here.")
  }

  // MARK: - Formatters are in CalendarFormatters

  // MARK: - Toolbar

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

  // Ask AI sheet is now a separate component
}

#Preview {
  let store = CalendarStore()
  // Seed some preview data
  Task { @MainActor in
    _ = try? await store.addEntry(
      title: "Team Standup",
      description: "Daily sync",
      startDate: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: .now)
        ?? .now,
      endDate: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: .now)
        ?? .now
    )
  }
  return NavigationStack { CalendarScreenView(store: store) }
}
