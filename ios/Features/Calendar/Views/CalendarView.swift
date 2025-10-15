import SwiftUI
import Observation

struct CalendarView: View {
    @Bindable var store: CalendarStore
    var onAskAI: (() -> Void)? = nil

    @State private var months: [Month] = []
    @State private var isInitialLoading = false
    @State private var isLoadingMore = false
    @State private var isAskAISheetPresented = false
    @State private var askAIText: String = ""
    @State private var isAddEventSheetPresented = false
    @State private var editingEntry: CalendarEntry?
    private let initialMonthBatch = 6
    private let subsequentBatch = 3

    var body: some View {
        Group { content }
            .toolbar { toolbarContent }
            .sheet(isPresented: $isAskAISheetPresented) {
                askAISheet
                    .presentationDetents([.height(420), .height(700)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(24)
            }
            .sheet(isPresented: $isAddEventSheetPresented) {
                EventEntrySheetView(
                    mode: .add,
                    onSave: { title, desc, start, end in
                        _ = try await store.addEntry(title: title, description: desc, startDate: start, endDate: end)
                        // Reload months to reflect new event (lightweight; could also insert more surgically)
                        months = await store.months(from: .now, count: max(months.count, initialMonthBatch))
                        isAddEventSheetPresented = false
                    },
                    onCancel: { isAddEventSheetPresented = false }
                )
                .presentationDetents([.height(520), .large])
                .presentationDragIndicator(.visible)
            }
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
                        months = await store.months(from: .now, count: max(months.count, initialMonthBatch))
                        editingEntry = nil
                    },
                    onCancel: { editingEntry = nil }
                )
                .presentationDetents([.height(520), .large])
                .presentationDragIndicator(.visible)
            }
            .task { await loadInitialMonths() }
            .refreshable { await reloadFromToday() }
    }

    // MARK: - Loading

    private func loadInitialMonths() async {
        guard months.isEmpty else { return }
        isInitialLoading = true
        months = await store.months(from: .now, count: initialMonthBatch)
        isInitialLoading = false
    }

    private func loadMoreMonthsIfNeeded() async {
        guard !isLoadingMore else { return }
        guard let last = months.last else { return }
        isLoadingMore = true
        let nextStart = Month.nextMonthStart(after: last.firstDay)
        let more = await store.months(from: nextStart, count: subsequentBatch)
        months.append(contentsOf: more)
        isLoadingMore = false
    }

    private func reloadFromToday() async {
        months = []
        await loadInitialMonths()
    }

    // MARK: - View Builders

    @ViewBuilder
    private var content: some View {
        if isInitialLoading && months.isEmpty {
            loadingView
        } else if months.isEmpty {
            emptyState
        } else {
            listContent
        }
    }


    private var listContent: some View {
        List {
            ForEach(Array(months.enumerated()), id: \.element.id) { index, month in
                MonthSectionView(
                    month: month,
                    index: index,
                    totalCount: months.count,
                    isLoadingMore: isLoadingMore,
                    onNearEndAppear: { Task { await loadMoreMonthsIfNeeded() } },
                    onEventSelected: { entry in editingEntry = entry }
                )
            }
        }
        .listStyle(.insetGrouped)
    }

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

    // MARK: - Ask AI Sheet

    private var askAISheet: some View {
        VStack(spacing: 12) {
            TextEditor(text: $askAIText)
                .scrollContentBackground(.hidden)
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)
                .padding(.top)

            Button {
                // Placeholder action; wire to AI flow as needed
                isAskAISheetPresented = false
            } label: {
                Label("Ask AI", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}


#Preview {
    let store = CalendarStore()
    // Seed some preview data
    Task { @MainActor in
        _ = try? await store.addEntry(
            title: "Team Standup",
            description: "Daily sync",
            startDate: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: .now) ?? .now,
            endDate: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: .now) ?? .now
        )
    }
    return NavigationStack { CalendarView(store: store) }
}
