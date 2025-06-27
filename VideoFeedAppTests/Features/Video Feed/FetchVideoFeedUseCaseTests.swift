import Testing
import Foundation
@testable import VideoFeedApp

struct FetchVideoFeedUseCaseTests {
    
    @Test("FetchVideoFeedUseCase should return videos and cursor on success")
    func execute_withValidService_returnsMappedVideosAndCursor() async throws {
        // Given
        let mockService = MockVideoFeedAPIService()
        let creatorDTO = CreatorDTO(id: "user1", name: "Test User", avatarURL: "https://example.com/avatar.jpg")
        let videoDTO = VideoDTO(
            id: "video1",
            creator: creatorDTO,
            shortVideoURL: "https://example.com/short.mp4",
            fullVideoURL: "https://example.com/full.mp4",
            description: "Test video",
            likes: 100,
            comments: 10
        )
        mockService.videosToReturn = [videoDTO]
        mockService.nextCursorToReturn = "next_cursor_123"
        
        let useCase = FetchVideoFeedUseCase(service: mockService)
        
        // When
        let (videos, cursor) = try await useCase.fetchVideoFeed(cursor: nil, limit: 5)
        
        // Then
        #expect(videos.count == 1)
        #expect(videos.first?.id == "video1")
        #expect(videos.first?.creator.name == "Test User")
        #expect(videos.first?.likeCount == 100)
        #expect(cursor == "next_cursor_123")
        #expect(mockService.lastCursorReceived == nil)
        #expect(mockService.lastLimitReceived == 5)
    }
    
    @Test("FetchVideoFeedUseCase should propagate errors")
    func execute_withFailingService_throwsError() async throws {
        // Given
        let mockService = MockVideoFeedAPIService()
        mockService.shouldThrowError = true
        
        let useCase = FetchVideoFeedUseCase(service: mockService)
        
        // When & Then
        await #expect(throws: URLError.self) {
            try await useCase.fetchVideoFeed(cursor: nil, limit: 5)
        }
    }
    
    @Test("FetchVideoFeedUseCase should map multiple videos correctly")
    func execute_withMultipleVideos_returnsMappedVideoArray() async throws {
        // Given
        let mockService = MockVideoFeedAPIService()
        let videos = [
            VideoDTO(
                id: "video1", 
                creator: CreatorDTO(id: "user1", name: "User 1", avatarURL: "https://example.com/avatar1.jpg"),
                shortVideoURL: "url1", 
                fullVideoURL: "fullurl1", 
                description: "Caption 1", 
                likes: 10, 
                comments: 1
            ),
            VideoDTO(
                id: "video2", 
                creator: CreatorDTO(id: "user2", name: "User 2", avatarURL: "https://example.com/avatar2.jpg"),
                shortVideoURL: "url2", 
                fullVideoURL: "fullurl2", 
                description: "Caption 2", 
                likes: 20, 
                comments: 2
            )
        ]
        mockService.videosToReturn = videos
        mockService.nextCursorToReturn = nil
        
        let useCase = FetchVideoFeedUseCase(service: mockService)
        
        // When
        let (result, cursor) = try await useCase.fetchVideoFeed(cursor: "previous_cursor", limit: 10)
        
        // Then
        #expect(result.count == 2)
        #expect(result[0].id == "video1")
        #expect(result[1].id == "video2")
        #expect(result[0].creator.name == "User 1")
        #expect(result[1].creator.name == "User 2")
        #expect(cursor == nil)
        #expect(mockService.lastCursorReceived == "previous_cursor")
        #expect(mockService.lastLimitReceived == 10)
    }
    
    @Test("FetchVideoFeedUseCase should handle pagination with cursor")
    func execute_withCursor_passesCorrectParameters() async throws {
        // Given
        let mockService = MockVideoFeedAPIService()
        let videos = [
            VideoDTO(
                id: "video3", 
                creator: CreatorDTO(id: "user3", name: "User 3", avatarURL: "https://example.com/avatar3.jpg"),
                shortVideoURL: "url3", 
                fullVideoURL: "fullurl3", 
                description: "Caption 3", 
                likes: 30, 
                comments: 3
            )
        ]
        mockService.videosToReturn = videos
        mockService.nextCursorToReturn = "final_cursor"
        
        let useCase = FetchVideoFeedUseCase(service: mockService)
        
        // When
        let (result, nextCursor) = try await useCase.fetchVideoFeed(cursor: "page_2_cursor", limit: 20)
        
        // Then
        #expect(result.count == 1)
        #expect(result[0].id == "video3")
        #expect(nextCursor == "final_cursor")
        #expect(mockService.lastCursorReceived == "page_2_cursor")
        #expect(mockService.lastLimitReceived == 20)
        #expect(mockService.callCount == 1)
    }
} 
