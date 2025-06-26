import Testing
import Foundation
@testable import VideoFeedApp

struct VideoFeedMockDataManagerTests {
    
    @Test("MockDataManager should load video feed")
    func loadVideoFeedResponse_withValidJSON_returnsVideoArray() async throws {
        // Given
        let sut = VideoFeedMockDataManager()
        
        // When
        let videos = try sut.loadVideoFeedResponse()
        
        // Then
        #expect(videos.count == 5) // Expected from video_feed_mock.json
        #expect(videos.first?.id != nil)
        #expect(videos.first?.creator.name != nil)
        
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
    
    @Test("MockDataManager should handle invalid file gracefully")
    func loadVideoFeedResponse_withInvalidFile_throwsError() async throws {
        // Given
        let sut = VideoFeedMockDataManager()
        
        // When & Then
        #expect(throws: Error.self) {
            try sut.loadVideoFeedResponse(fileName: "nonexistent_file")
        }
    }
} 
