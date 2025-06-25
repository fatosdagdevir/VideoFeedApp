import Foundation

@MainActor
final class VideoFeedViewModel: ObservableObject {
    private let navigator: Navigating

    init(
        navigator: Navigating
    ) {
        self.navigator = navigator
    }
}
