import SwiftUI

enum NavigationDestination: Hashable {
    case photoDetail(id: Int)
}

protocol Navigating {
    func navigate(to destination: NavigationDestination)
    func navigateBack()
    func navigateToRoot()
}

final class Navigator: Navigating, ObservableObject {
    @Published public var path = NavigationPath()
    
    func navigate(to destination: NavigationDestination) {
        path.append(destination)
    }
    
    func navigateBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func navigateToRoot() {
        guard !path.isEmpty else { return }
        path.removeLast(path.count)
    }
}
