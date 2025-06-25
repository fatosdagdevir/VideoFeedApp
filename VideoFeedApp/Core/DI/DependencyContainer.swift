import Foundation
import SwiftUI
import Networking

@MainActor
final class DependencyContainer {
    let navigator: Navigator
    
    init() {
        self.navigator = Navigator()
    }
}
