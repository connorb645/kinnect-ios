import Observation
import SwiftUINavigation

extension CalendarRootScreenView {
  @Observable
  public class ScreenState {
    public static var initial: ScreenState {
      ScreenState()
    }

    // MARK: - Types
    @CasePathable
    public enum Destination {
      public enum SheetDestination {
        case askAI
      }

      case sheet(SheetDestination)
    }

    // MARK: - State
    public var destination: Destination? = nil
  }
}
