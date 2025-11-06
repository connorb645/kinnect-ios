import SwiftUI

struct AskAISheetView: View {
    @Binding var text: String
    var onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            TextEditor(text: $text)
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

            Button(action: onSubmit) {
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
    struct Wrapper: View {
        @State var text: String = ""
        var body: some View {
            AskAISheetView(text: $text) {}
        }
    }
    return Wrapper()
}

