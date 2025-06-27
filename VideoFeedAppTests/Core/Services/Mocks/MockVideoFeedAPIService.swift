import Foundation
@testable import VideoFeedApp

final class MockVideoFeedAPIService: VideoFeedAPIServiceProtocol {
    var shouldThrowError = false
    var videosToReturn: [VideoDTO] = []
    var nextCursorToReturn: String?
    var callCount = 0
    var lastCursorReceived: String?
    var lastLimitReceived: Int?
    
    func fetchVideoFeed(cursor: String?, limit: Int) async throws -> ([VideoDTO], String?) {
        callCount += 1
        lastCursorReceived = cursor
        lastLimitReceived = limit
        
        if shouldThrowError {
            throw URLError(.networkConnectionLost)
        }
        
        return (videosToReturn, nextCursorToReturn)
    }
} 
