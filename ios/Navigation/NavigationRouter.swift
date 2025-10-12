import Foundation
import Observation

@Observable
final class NavigationRouter {
    var path: [AppRoute] = []

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        _ = path.popLast()
    }

    func popToRoot() {
        path.removeAll()
    }

    func setPath(_ newPath: [AppRoute]) {
        path = newPath
    }
}
