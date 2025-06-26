import Foundation
@testable import VideoFeedApp

final class MockVideoFeedAPIService: VideoFeedAPIServiceProtocol {
    var shouldThrowError = false
    var videosToReturn: [VideoDTO] = []
    
    func fetchVideoFeed() async throws -> [VideoDTO] {
        if shouldThrowError {
            throw URLError(.networkConnectionLost)
        }
        return videosToReturn
    }
} 
