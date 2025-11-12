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
    TabView(selection: $screenState.currentPageIndex) {
      DatePageView(date: screenState.dateBuffer.item(at: 0))
        .tag(0)
      DatePageView(date: screenState.dateBuffer.item(at: 1))
        .tag(1)
      DatePageView(date: screenState.dateBuffer.item(at: 2))
        .tag(2)
    }
    .tabViewStyle(.page(indexDisplayMode: .never))
    .onChange(of: screenState.currentPageIndex) { oldValue, newValue in
      var transaction = Transaction()
      transaction.disablesAnimations = true
      withTransaction(transaction) {
        screenState.handlePageChange(newIndex: newValue, oldIndex: oldValue)
      }
    }
  }

  @ViewBuilder
  private func DatePageView(date: Date) -> some View {
    Text(date, style: .date)
      .font(.largeTitle)
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

#Preview {
  NavigationStack {
    CalendarRootScreenView(initialState: CalendarRootScreenView.ScreenState())
  }
}
