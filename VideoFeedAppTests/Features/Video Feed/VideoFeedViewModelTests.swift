import Testing
import Foundation
@testable import VideoFeedApp

struct VideoFeedViewModelTests {
    
    @Test("ViewModel should initialize with loading state")
    @MainActor
    func init_withValidDependencies_createsViewModelWithLoadingState() async throws {
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
        if case .loading = sut.viewState {
            // Success
        } else {
            #expect(Bool(false), "Expected loading state")
        }
    }
    
    @Test("ViewModel should load videos successfully and set ready state")
    @MainActor
    func loadVideoFeed_withValidVideos_setsReadyStateWithVideos() async throws {
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
        mockAPIService.nextCursorToReturn = "next_cursor_123"
        let useCase = FetchVideoFeedUseCase(service: mockAPIService)
        
        let sut = VideoFeedViewModel(
            navigator: mockNavigator,
            fetchVideosUseCase: useCase
        )
        
        // When
        await sut.loadVideoFeed()
        
        // Then
        if case .ready(let videos) = sut.viewState {
            #expect(videos.count == 2)
            #expect(videos[0].id == "video1")
            #expect(videos[1].id == "video2")
            #expect(videos[0].creator.name == "User 1")
            #expect(videos[1].creator.name == "User 2")
            #expect(sut.nextPageAvailable == true)
        } else {
            #expect(Bool(false), "Expected ready state with videos")
        }
    }
    
    @Test("ViewModel should handle empty video list and set empty state")
    @MainActor
    func loadVideoFeed_withEmptyResponse_setsEmptyState() async throws {
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
        if case .empty = viewModel.viewState {
            // Success
        } else {
            #expect(Bool(false), "Expected empty state")
        }
    }
    
    @Test("ViewModel should handle API errors and set error state")
    @MainActor
    func loadVideoFeed_withAPIError_setsErrorState() async throws {
        // Given
        let mockNavigator = MockNavigator()
        let mockAPIService = MockVideoFeedAPIService()
        mockAPIService.shouldThrowError = true
        let useCase = FetchVideoFeedUseCase(service: mockAPIService)
        
        let viewModel = VideoFeedViewModel(
            navigator: mockNavigator,
            fetchVideosUseCase: useCase
        )
        
        // When
        await viewModel.loadVideoFeed()
        
        // Then
        if case .error(let errorViewModel) = viewModel.viewState {
            #expect(errorViewModel.headerText.isEmpty == false)
        } else {
            #expect(Bool(false), "Expected error state")
        }
    }
    
    @Test("ViewModel should load more videos when next page is available")
    @MainActor
    func loadMore_withNextPageAvailable_appendsNewVideos() async throws {
        // Given
        let mockNavigator = MockNavigator()
        let mockAPIService = MockVideoFeedAPIService()
        
        // First batch
        let firstBatchVideos = [
            VideoDTO(
                id: "video1",
                creator: CreatorDTO(id: "user1", name: "User 1", avatarURL: "https://example.com/avatar1.jpg"),
                shortVideoURL: "https://example.com/video1.mp4",
                fullVideoURL: "https://example.com/full1.mp4",
                description: "Test video 1",
                likes: 100,
                comments: 10
            )
        ]
        
        mockAPIService.videosToReturn = firstBatchVideos
        mockAPIService.nextCursorToReturn = "cursor_123"
        let useCase = FetchVideoFeedUseCase(service: mockAPIService)
        
        let viewModel = VideoFeedViewModel(
            navigator: mockNavigator,
            fetchVideosUseCase: useCase
        )
        
        // Load initial videos
        await viewModel.loadVideoFeed()
        
        // Second batch
        let secondBatchVideos = [
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
        
        mockAPIService.videosToReturn = secondBatchVideos
        mockAPIService.nextCursorToReturn = nil // No more pages
        
        // When
        await viewModel.loadMore()
        
        // Then
        if case .ready(let videos) = viewModel.viewState {
            #expect(videos.count == 2)
            #expect(videos[0].id == "video1")
            #expect(videos[1].id == "video2")
            #expect(viewModel.nextPageAvailable == false)
        } else {
            #expect(Bool(false), "Expected ready state with appended videos")
        }
    }
    
    @Test("ViewModel should not load more when no next page available")
    @MainActor
    func loadMore_withNoNextPage_doesNotLoadMore() async throws {
        // Given
        let mockNavigator = MockNavigator()
        let mockAPIService = MockVideoFeedAPIService()
        
        let videos = [
            VideoDTO(
                id: "video1",
                creator: CreatorDTO(id: "user1", name: "User 1", avatarURL: "https://example.com/avatar1.jpg"),
                shortVideoURL: "https://example.com/video1.mp4",
                fullVideoURL: "https://example.com/full1.mp4",
                description: "Test video 1",
                likes: 100,
                comments: 10
            )
        ]
        
        mockAPIService.videosToReturn = videos
        mockAPIService.nextCursorToReturn = nil // No more pages
        let useCase = FetchVideoFeedUseCase(service: mockAPIService)
        
        let viewModel = VideoFeedViewModel(
            navigator: mockNavigator,
            fetchVideosUseCase: useCase
        )
        
        await viewModel.loadVideoFeed()
        let initialCallCount = mockAPIService.callCount
        
        // When
        await viewModel.loadMore()
        
        // Then
        #expect(mockAPIService.callCount == initialCallCount) // No additional call made
        #expect(viewModel.nextPageAvailable == false)
    }
    
    @Test("ViewModel should refresh and reload from beginning")
    @MainActor
    func refresh_withExistingVideos_reloadsFromBeginning() async throws {
        // Given
        let mockNavigator = MockNavigator()
        let mockAPIService = MockVideoFeedAPIService()
        
        let initialVideos = [
            VideoDTO(
                id: "video1",
                creator: CreatorDTO(id: "user1", name: "User 1", avatarURL: "https://example.com/avatar1.jpg"),
                shortVideoURL: "https://example.com/video1.mp4",
                fullVideoURL: "https://example.com/full1.mp4",
                description: "Test video 1",
                likes: 100,
                comments: 10
            )
        ]
        
        mockAPIService.videosToReturn = initialVideos
        mockAPIService.nextCursorToReturn = "cursor_123"
        let useCase = FetchVideoFeedUseCase(service: mockAPIService)
        
        let viewModel = VideoFeedViewModel(
            navigator: mockNavigator,
            fetchVideosUseCase: useCase
        )
        
        await viewModel.loadVideoFeed()
        
        let refreshedVideos = [
            VideoDTO(
                id: "video2",
                creator: CreatorDTO(id: "user2", name: "User 2", avatarURL: "https://example.com/avatar2.jpg"),
                shortVideoURL: "https://example.com/video2.mp4",
                fullVideoURL: "https://example.com/full2.mp4",
                description: "Refreshed video",
                likes: 300,
                comments: 30
            )
        ]
        
        mockAPIService.videosToReturn = refreshedVideos
        mockAPIService.nextCursorToReturn = nil
        
        // When
        await viewModel.refresh()
        
        // Then
        if case .ready(let videos) = viewModel.viewState {
            #expect(videos.count == 1)
            #expect(videos[0].id == "video2")
            #expect(videos[0].caption == "Refreshed video")
        } else {
            #expect(Bool(false), "Expected ready state with refreshed videos")
        }
    }
}
