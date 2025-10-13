import SwiftUI

struct HomeView: View {
    @State private var store = CalendarStore()

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

