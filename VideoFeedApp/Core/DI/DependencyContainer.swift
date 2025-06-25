import Foundation

@MainActor
final class DependencyContainer {
    let navigator: Navigator
    
    init() {
        self.navigator = Navigator()
    }
}
