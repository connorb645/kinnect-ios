import SwiftUI

struct AddEventSheetView: View {
    var onSave: (_ title: String, _ description: String?, _ start: Date, _ end: Date) async throws -> Void
    var onCancel: (() -> Void)?

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(60 * 60)
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    TextField("Description (optional)", text: $description)
                }
                Section("When") {
                    DatePicker("Starts", selection: $startDate)
                        .onChange(of: startDate) { old, newValue in
                            // Ensure end stays after start
                            if endDate <= newValue {
                                endDate = newValue.addingTimeInterval(30 * 60)
                            }
                        }
                    DatePicker("Ends", selection: $endDate, in: startDate...)
                        .onChange(of: endDate) { old, newValue in
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
                        if isSaving { ProgressView() } else { Text("Save Event") }
                    }
                    .disabled(!isFormValid || isSaving)
                }
            }
            .navigationTitle("New Event")
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

    private func save() {
        guard !isSaving else { return }
        isSaving = true
        Task {
            do {
                try await onSave(
                    title.trimmingCharacters(in: .whitespacesAndNewlines),
                    description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description,
                    startDate,
                    endDate
                )
            } catch {
                errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
            isSaving = false
        }
    }
}

#Preview {
    AddEventSheetView(onSave: { _,_,_,_ in }, onCancel: {})
}
