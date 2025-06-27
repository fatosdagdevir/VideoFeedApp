import Testing
import Foundation
@testable import VideoFeedApp

struct VideoFeedAPIServiceTests {
    
    @Test("VideoFeedAPIService should work in mock environment")
    func fetchVideoFeed_inMockEnvironment_returnsVideosFromMockData() async throws {
        // Given
        let apiService = VideoFeedAPIService()
        
        // When
        let (videos, _) = try await apiService.fetchVideoFeed(cursor: nil, limit: 5)
        
        // Then
        #expect(videos.count == 5) // Expected from video_feed_mock.json
        #expect(videos.first?.id != nil)
        #expect(videos.first?.creator.name != nil)
        #expect(videos.first?.shortVideoURL != nil)
    }

    @Test("VideoFeedAPIService should return valid DTOs")
    func fetchVideoFeed_inMockEnvironment_returnsValidDTOs() async throws {
        // Given
        let apiService = VideoFeedAPIService()
        
        // When
        let (videos, _) = try await apiService.fetchVideoFeed(cursor: nil, limit: 5)
        
        // Then
        for video in videos {
            #expect(!video.id.isEmpty)
            #expect(!video.creator.id.isEmpty)
            #expect(!video.creator.name.isEmpty)
            #expect(!video.shortVideoURL.isEmpty)
            #expect(!video.description.isEmpty)
            #expect(video.likes >= 0)
            #expect(video.comments >= 0)
        }
    }
} 
