import SwiftUI
import Observation

struct CalendarView: View {
    @Bindable var store: CalendarStore

    @State private var months: [Month] = []
    @State private var isInitialLoading = false
    @State private var isLoadingMore = false
    private let initialMonthBatch = 6
    private let subsequentBatch = 3

    var body: some View {
        Group { content }
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
                monthSection(for: index, month: month)
            }
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    private func monthSection(for index: Int, month: Month) -> some View {
        Section(header: Text(Self.monthHeaderFormatter.string(from: month.firstDay))) {
            if month.days.isEmpty {
                Text("No days in this month")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(month.days) { day in
                    dayBlock(for: day)
                }
            }
            paginationFooterIfNeeded(for: index)
        }
    }

    @ViewBuilder
    private func dayBlock(for day: Day) -> some View {
        if day.events.isEmpty {
            Text(Self.dayFormatter.string(from: day.date))
                .foregroundStyle(.secondary)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text(Self.dayFormatter.string(from: day.date))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ForEach(day.events) { event in
                    eventRow(event)
                }
            }
            .padding(.vertical, 6)
        }
    }

    @ViewBuilder
    private func eventRow(_ event: CalendarEntry) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.title)
                .font(.headline)
            Text("\(Self.timeFormatter.string(from: event.startDate)) — \(Self.timeFormatter.string(from: event.endDate))")
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

    @ViewBuilder
    private func paginationFooterIfNeeded(for index: Int) -> some View {
        if index >= months.count - 2 { // Prefetch near the end
            HStack {
                Spacer()
                if isLoadingMore { ProgressView().padding(.vertical, 8) }
                Spacer()
            }
            .onAppear { Task { await loadMoreMonthsIfNeeded() } }
        }
    }

    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyState: some View {
        Text("Your upcoming months will appear here.")
    }

    // MARK: - Formatters

    private static let monthHeaderFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "LLLL yyyy"
        return df
    }()

    private static let dayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .full
        df.timeStyle = .none
        return df
    }()

    private static let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        return df
    }()
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
