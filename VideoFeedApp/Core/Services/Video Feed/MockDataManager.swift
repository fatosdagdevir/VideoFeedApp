import Foundation

// MARK: - Video Feed Mock Data Manager Protocol
protocol VideoFeedMockDataManaging {
    func loadJSON<T: Codable>(fileName: String, type: T.Type) throws -> T
    func loadVideoFeedResponse(fileName: String) throws -> [VideoDTO]
}

extension VideoFeedMockDataManaging {
    func loadVideoFeedResponse() throws -> [VideoDTO] {
        try loadVideoFeedResponse(fileName: "video_feed_mock")
    }
}

// MARK: - Video Feed Mock Data Manager Implementation
final class VideoFeedMockDataManager: VideoFeedMockDataManaging {
    private let bundle: Bundle
    
    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }
    
    func loadJSON<T: Codable>(fileName: String, type: T.Type) throws -> T {
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw URLError(.fileDoesNotExist)
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    }
    
    func loadVideoFeedResponse(fileName: String) throws -> [VideoDTO] {
        let response = try loadJSON(fileName: fileName, type: VideoFeedResponse.self)
        return response.videos
    }
}

