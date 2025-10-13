import SwiftUI

struct HomeView: View {
    @State private var store: CalendarStore

    init(store: CalendarStore = CalendarStore()) {
        _store = State(initialValue: store)
    }

    var body: some View {
        NavigationStack {
            CalendarView(store: store)
                .navigationTitle("Calendar")
        }
    }
}

#Preview {
    HomeView()
}
