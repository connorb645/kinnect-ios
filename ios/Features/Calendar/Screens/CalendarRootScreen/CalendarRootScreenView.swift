import Observation
import SwiftUI
import SwiftUINavigation

struct CalendarRootScreenView: View {
  @State private var screenState = ScreenState()

  init(
    initialState: ScreenState,
  ) {
    self.screenState = initialState
  }

  var body: some View {
    Group { content }
      .fontDesign(.monospaced)
      .navigationTitle("")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar { toolbarContent }
      .sheet(item: $screenState.destination.sheet, id: \.self) { $destination in
        switch destination {
        case .askAI:
          Text("Ask AI")
        }
      }
  }

  @ViewBuilder
  private var content: some View {
    Text("Calendar Root Screen")
  }

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .navigationBarTrailing) {
      Menu {
        Button {
          screenState.destination = .sheet(.askAI)
        } label: {
          Label("Ask AI", systemImage: "sparkles")
        }
      } label: {
        Image(systemName: "plus")
      }
    }
  }
}

// #Preview {
//   let store = CalendarStore()
//   return NavigationStack { CalendarScreenView(store: store) }
// }
