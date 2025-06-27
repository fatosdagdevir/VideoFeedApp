import Foundation
import Networking

protocol VideoFeedAPIServiceProtocol {
    func fetchVideoFeed(cursor: String?, limit: Int) async throws -> ([VideoDTO], String?)
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
    
    func fetchVideoFeed(cursor: String?, limit: Int) async throws -> ([VideoDTO], String?) {
        switch config.environment {
        case .production:
            let response = try await fetchFromAPI()
            return response
        case .mock:
            try await Task.sleep(nanoseconds: UInt64(config.simulatedDelay * 1_000_000_000))
            return try mockDataManager.loadVideoFeedResponse(after: cursor, limit: limit)
        }
    }
    
    // MARK: - Private Methods
    private func fetchFromAPI() async throws -> ([VideoDTO], String?) {
        let endpoint = VideoFeedEndpoint()
        let request = VideoFeedRequest(endpoint: endpoint)
        let response = try await networking.send(request: request)
        return (response.videos, response.nextCursor)
    }
}

// MARK: - Video Feed
private struct VideoFeedEndpoint: EndpointProtocol {
    let host = AppConstants.API.baseURL
    let path = "/video-feed"
}

private struct VideoFeedRequest: RequestProtocol {
    typealias Response = VideoFeedResponse
    let endpoint: EndpointProtocol
    let method: HTTP.Method = .GET
}

struct VideoFeedResponse: Codable {
    let videos: [VideoDTO]
    let nextCursor: String?
}
