import Testing
import Foundation
@testable import VideoFeedApp

struct VideoFeedViewModelTests {
    
    @Test("ViewModel should initialize with empty videos array")
    @MainActor
    func init_withValidDependencies_createsViewModelWithEmptyVideos() async throws {
        // Given
        let mockNavigator = MockNavigator()
        let mockAPIService = MockVideoFeedAPIService()
        let useCase = FetchVideoFeedUseCase(service: mockAPIService)
        
        // When
        let sut = VideoFeedViewModel(
            navigator: mockNavigator,
            fetchVideosUseCase: useCase
        )
        
        // Then
        #expect(sut.videos.isEmpty)
    }
    
    @Test("ViewModel should load videos successfully")
    @MainActor
    func loadVideoFeed_withValidVideos_populatesVideosArray() async throws {
        // Given
        let mockNavigator = MockNavigator()
        let mockAPIService = MockVideoFeedAPIService()
        
        let expectedVideoDTOs = [
            VideoDTO(
                id: "video1",
                creator: CreatorDTO(id: "user1", name: "User 1", avatarURL: "https://example.com/avatar1.jpg"),
                shortVideoURL: "https://example.com/video1.mp4",
                fullVideoURL: "https://example.com/full1.mp4",
                description: "Test video 1",
                likes: 100,
                comments: 10
            ),
            VideoDTO(
                id: "video2",
                creator: CreatorDTO(id: "user2", name: "User 2", avatarURL: "https://example.com/avatar2.jpg"),
                shortVideoURL: "https://example.com/video2.mp4",
                fullVideoURL: "https://example.com/full2.mp4",
                description: "Test video 2",
                likes: 200,
                comments: 20
            )
        ]
        
        mockAPIService.videosToReturn = expectedVideoDTOs
        let useCase = FetchVideoFeedUseCase(service: mockAPIService)
        
        let sut = VideoFeedViewModel(
            navigator: mockNavigator,
            fetchVideosUseCase: useCase
        )
        
        // When
        await sut.loadVideoFeed()
        
        // Then
        #expect(sut.videos.count == 2)
        #expect(sut.videos[0].id == "video1")
        #expect(sut.videos[1].id == "video2")
        #expect(sut.videos[0].creator.name == "User 1")
        #expect(sut.videos[1].creator.name == "User 2")
    }
    
    @Test("ViewModel should handle empty video list")
    @MainActor
    func loadVideoFeed_withEmptyResponse_keepsVideosArrayEmpty() async throws {
        // Given
        let mockNavigator = MockNavigator()
        let mockAPIService = MockVideoFeedAPIService()
        mockAPIService.videosToReturn = []
        let useCase = FetchVideoFeedUseCase(service: mockAPIService)
        
        let viewModel = VideoFeedViewModel(
            navigator: mockNavigator,
            fetchVideosUseCase: useCase
        )
        
        // When
        await viewModel.loadVideoFeed()
        
        // Then
        #expect(viewModel.videos.isEmpty)
    }
}
