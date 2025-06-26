import Foundation
import SwiftUI
import Networking

@MainActor
final class DependencyContainer {
    let navigator: Navigator
    let networking: Networking
    let mockDataManager: VideoFeedMockDataManaging
    let videoFeedAPIService: VideoFeedAPIServiceProtocol
    
    init() {
        self.navigator = Navigator()
        self.networking = Network()
        self.mockDataManager = VideoFeedMockDataManager()
        self.videoFeedAPIService = VideoFeedAPIService(
            config: APIConfiguration.current,
            networking: networking,
            mockDataManager: mockDataManager
        )
    }
}
