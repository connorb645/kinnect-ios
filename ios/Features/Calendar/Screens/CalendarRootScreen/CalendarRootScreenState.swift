import Observation
import SwiftUINavigation

extension CalendarRootScreenView {
  @Observable
  public class ScreenState {
    // MARK: - Types
    @CasePathable
    public enum Destination {
      public enum SheetDestination {
        // case addEvent
        case askAI
      }

      case sheet(SheetDestination)
    }

    // MARK: - State
    public var destination: Destination? = nil

    static var initial = ScreenState()
  }
}
