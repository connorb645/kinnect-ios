import Foundation

enum AppRoute: Hashable, Codable {
  case auth
  case home
  case profile(id: UUID)
  case settings
}
