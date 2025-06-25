import SwiftUI

@main
struct VideoFeedAppApp: App {
    private let container: DependencyContainer

    init() {
        self.container = DependencyContainer()
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView(container: container)
        }
    }
}
