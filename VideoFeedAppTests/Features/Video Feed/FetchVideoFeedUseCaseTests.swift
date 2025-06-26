import Testing
import Foundation
@testable import VideoFeedApp

struct FetchVideoFeedUseCaseTests {
    
    @Test("FetchVideoFeedUseCase should return videos on success")
    func execute_withValidService_returnsMappedVideos() async throws {
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
        
        let useCase = FetchVideoFeedUseCase(service: mockService)
        
        // When
        let result = try await useCase.fetchVideoFeed()
        
        // Then
        #expect(result.count == 1)
        #expect(result.first?.id == "video1")
        #expect(result.first?.creator.name == "Test User")
        #expect(result.first?.likeCount == 100)
    }
    
    @Test("FetchVideoFeedUseCase should propagate errors")
    func execute_withFailingService_throwsError() async throws {
        // Given
        let mockService = MockVideoFeedAPIService()
        mockService.shouldThrowError = true
        
        let useCase = FetchVideoFeedUseCase(service: mockService)
        
        // When & Then
        await #expect(throws: URLError.self) {
            try await useCase.fetchVideoFeed()
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
        
        let useCase = FetchVideoFeedUseCase(service: mockService)
        
        // When
        let result = try await useCase.fetchVideoFeed()
        
        // Then
        #expect(result.count == 2)
        #expect(result[0].id == "video1")
        #expect(result[1].id == "video2")
        #expect(result[0].creator.name == "User 1")
        #expect(result[1].creator.name == "User 2")
    }
} 
