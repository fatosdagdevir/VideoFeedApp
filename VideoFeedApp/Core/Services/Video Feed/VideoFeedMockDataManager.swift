import Foundation

// MARK: - Mock Data Manager Protocol
protocol VideoFeedMockDataManaging {
    func loadJSON<T: Codable>(fileName: String, type: T.Type) throws -> T
    func loadVideoFeedResponse(fileName: String, after cursor: String?, limit: Int) throws -> ([VideoDTO], String?)
}

extension VideoFeedMockDataManaging {
    func loadVideoFeedResponse(after cursor: String?, limit: Int) throws -> ([VideoDTO], String?) {
        try loadVideoFeedResponse(fileName: "video_feed_mock", after: cursor, limit: limit)
    }
}

// MARK: - Mock Data Manager Implementation
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
    
    func loadVideoFeedResponse2(fileName: String) throws -> ([VideoDTO], String?) {
        let response = try loadJSON(fileName: fileName, type: VideoFeedResponse.self)
        return (response.videos, response.nextCursor)
    }
    
    func loadVideoFeedResponse(fileName: String, after cursor: String?, limit: Int = 5) throws -> ([VideoDTO], String?) {
        let response = try loadJSON(fileName: fileName, type: VideoFeedResponse.self)
        let allVideos = response.videos
        
        // Find the start index after the cursor
        let startIndex: Int
        if let cursor = cursor,
           let index = allVideos.firstIndex(where: { $0.id == cursor }) {
            startIndex = index + 1
        } else {
            startIndex = 0
        }
        
        // Get the slice for this "page"
        let slice = allVideos.dropFirst(startIndex).prefix(limit)
        let videosPage = Array(slice)
        
        // Determine nextCursor
        let nextCursor = videosPage.last.map { $0.id }
        
        return (videosPage, nextCursor)
    }
}

