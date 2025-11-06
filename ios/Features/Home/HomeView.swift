import SwiftUI

struct HomeView: View {
    @State private var store: CalendarStore
    @State private var theme = AppTheme()

    init(store: CalendarStore = CalendarStore()) {
        _store = State(initialValue: store)
    }

    var body: some View {
        NavigationStack {
            CalendarScreenView(store: store)
                .navigationBarTitleDisplayMode(.inline)
        }
        .environment(theme)
    }
}

#Preview {
    HomeView()
}
