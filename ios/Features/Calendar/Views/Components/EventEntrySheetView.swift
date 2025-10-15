import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct EventEntrySheetView: View {
    enum Mode: Equatable {
        case add
        case edit(CalendarEntry)
    }

    private let mode: Mode
    var onSave: (_ title: String, _ description: String?, _ start: Date, _ end: Date) async throws -> Void
    var onCancel: (() -> Void)?

    @State private var title: String
    @State private var description: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(
        mode: Mode = .add,
        onSave: @escaping (_ title: String, _ description: String?, _ start: Date, _ end: Date) async throws -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        self.mode = mode
        self.onSave = onSave
        self.onCancel = onCancel

        let existing: CalendarEntry? = {
            if case let .edit(entry) = mode { return entry }
            return nil
        }()

        _title = State(initialValue: existing?.title ?? "")
        _description = State(initialValue: existing?.eventDescription ?? "")
        let defaultStart = Date()
        let defaultEnd = defaultStart.addingTimeInterval(60 * 60)
        _startDate = State(initialValue: existing?.startDate ?? defaultStart)
        _endDate = State(initialValue: existing?.endDate ?? defaultEnd)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    TextField("Description (optional)", text: $description)
                }
                Section("When") {
                    DatePicker("Starts", selection: $startDate)
                        .onChange(of: startDate) { _, newValue in
                            if endDate <= newValue {
                                endDate = newValue.addingTimeInterval(30 * 60)
                            }
                        }
                    DatePicker("Ends", selection: $endDate, in: startDate...)
                        .onChange(of: endDate) { _, newValue in
                            if newValue <= startDate {
                                endDate = startDate.addingTimeInterval(30 * 60)
                            }
                        }
                    if !isDateRangeValid {
                        Text("End must be after start")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
                Section {
                    Button(action: save) {
                        if isSaving { ProgressView() } else { Text(primaryButtonTitle) }
                    }
                    .disabled(!isFormValid || isSaving)
                }
            }
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel?() }
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil), actions: {
                Button("OK") { errorMessage = nil }
            }, message: {
                Text(errorMessage ?? "")
            })
        }
    }

    private var isDateRangeValid: Bool { endDate > startDate }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isDateRangeValid
    }

    private var navigationTitle: String {
        switch mode {
        case .add: return "New Event"
        case .edit: return "Edit Event"
        }
    }

    private var primaryButtonTitle: String {
        switch mode {
        case .add: return "Save Event"
        case .edit: return "Save Changes"
        }
    }

    private func save() {
        guard !isSaving else { return }
        isSaving = true
        Task { @MainActor in
            defer { isSaving = false }

            do {
                let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
                try await onSave(
                    trimmedTitle,
                    trimmedDescription.isEmpty ? nil : trimmedDescription,
                    startDate,
                    endDate
                )
#if canImport(UIKit)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
#endif
            } catch {
#if canImport(UIKit)
                UINotificationFeedbackGenerator().notificationOccurred(.error)
#endif
                errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
        }
    }
}

#Preview {
    EventEntrySheetView(onSave: { _, _, _, _ in }, onCancel: {})
}
