import Foundation
import Networking

protocol VideoFeedAPIServiceProtocol {
    func fetchVideoFeed() async throws -> [VideoDTO]
}

final class VideoFeedAPIService: VideoFeedAPIServiceProtocol {
    private let config: APIConfiguration
    private let networking: Networking
    private let mockDataManager: VideoFeedMockDataManaging
    
    init(
        config: APIConfiguration = APIConfiguration.current,
        networking: Networking = Network(),
        mockDataManager: VideoFeedMockDataManaging = VideoFeedMockDataManager()
    ) {
        self.config = config
        self.networking = networking
        self.mockDataManager = mockDataManager
    }
    
    func fetchVideoFeed() async throws -> [VideoDTO] {
        switch config.environment {
        case .production:
            return try await fetchFromAPI()
        case .mock:
            try await Task.sleep(nanoseconds: UInt64(config.simulatedDelay * 1_000_000_000))
            return try mockDataManager.loadVideoFeedResponse()
        }
    }
    
    // MARK: - Private Methods
    private func fetchFromAPI() async throws -> [VideoDTO] {
        let endpoint = VideoFeedEndpoint()
        let request = VideoFeedRequest(endpoint: endpoint)
        return try await networking.send(request: request)
    }
}

// MARK: - Video Feed
private struct VideoFeedEndpoint: EndpointProtocol {
    let host = AppConstants.API.baseURL
    let path = "/video-feed"
}

private struct VideoFeedRequest: RequestProtocol {
    typealias Response = [VideoDTO]
    let endpoint: EndpointProtocol
    let method: HTTP.Method = .GET
}

struct VideoFeedResponse: Codable {
    let videos: [VideoDTO]
}
