//
//  VideoFeedAppTests.swift
//  VideoFeedAppTests
//
//  Created by Fatma Dagdevir on 24.06.25.
//

import Testing
import Foundation
@testable import VideoFeedApp

// MARK: - Mock API Service for Testing
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

struct VideoFeedAppTests {

    // MARK: - Configuration Tests
    @Test("App configuration should use mock environment by default")
    func testAppDefaultConfiguration() async throws {
        let config = APIConfiguration.current
        #expect(config.environment == .mock)
    }

    // MARK: - Dependency Injection Tests
    @Test("Dependency container should provide video feed service")
    @MainActor
    func testDependencyContainerProvidesVideoFeedService() async throws {
        let container = DependencyContainer()
        let service = container.videoFeedAPIService
        #expect(service is VideoFeedAPIService)
    }

    // MARK: - Domain Model Tests
    @Test("Video should initialize with correct properties")
    func testVideoInitialization() async throws {
        // Given
        let creator = Creator(
            id: "user1",
            name: "Test User",
            avatarURL: "https://example.com/avatar.jpg"
        )
        
        // When
        let video = Video(
            id: "video1",
            creator: creator,
            shortVideoURL: "https://example.com/short.mp4",
            fullVideoURL: "https://example.com/full.mp4",
            caption: "Test video",
            likeCount: 100,
            commentCount: 10
        )
        
        // Then
        #expect(video.id == "video1")
        #expect(video.creator.id == "user1")
        #expect(video.shortVideoURL == "https://example.com/short.mp4")
        #expect(video.fullVideoURL == "https://example.com/full.mp4")
        #expect(video.caption == "Test video")
        #expect(video.likeCount == 100)
        #expect(video.commentCount == 10)
    }

    @Test("Creator should initialize with correct properties")
    func testCreatorInitialization() async throws {
        // When
        let creator = Creator(
            id: "creator123",
            name: "John Doe",
            avatarURL: "https://example.com/avatar.jpg"
        )
        
        // Then
        #expect(creator.id == "creator123")
        #expect(creator.name == "John Doe")
        #expect(creator.avatarURL == "https://example.com/avatar.jpg")
    }

    // MARK: - DTO Mapping Tests
    @Test("VideoDTO should map to Video correctly")
    func testVideoDTOMapping() async throws {
        // Given
        let creatorDTO = CreatorDTO(
            id: "user1",
            name: "Test Creator",
            avatarURL: "https://example.com/avatar.jpg"
        )
        
        let videoDTO = VideoDTO(
            id: "video123",
            creator: creatorDTO,
            shortVideoURL: "https://example.com/short.mp4",
            fullVideoURL: "https://example.com/full.mp4",
            description: "Amazing video!",
            likes: 1500,
            comments: 89
        )
        
        // When
        let video = videoDTO.mapped
        
        // Then
        #expect(video.id == "video123")
        #expect(video.creator.id == "user1")
        #expect(video.creator.name == "Test Creator")
        #expect(video.shortVideoURL == "https://example.com/short.mp4")
        #expect(video.fullVideoURL == "https://example.com/full.mp4")
        #expect(video.caption == "Amazing video!")
        #expect(video.likeCount == 1500)
        #expect(video.commentCount == 89)
    }

    @Test("CreatorDTO should map to Creator correctly")
    func testCreatorDTOMapping() async throws {
        // Given
        let creatorDTO = CreatorDTO(
            id: "creator123",
            name: "John Doe",
            avatarURL: "https://example.com/avatar.jpg"
        )
        
        // When
        let creator = creatorDTO.mapped
        
        // Then
        #expect(creator.id == "creator123")
        #expect(creator.name == "John Doe")
        #expect(creator.avatarURL == "https://example.com/avatar.jpg")
    }

    // MARK: - Mock Data Manager Tests
    @Test("Mock data manager should load video feed response")
    func testMockDataManagerLoadVideoFeed() async throws {
        // Given
        let mockDataManager = VideoFeedMockDataManager()
        
        // When
        let videos = try mockDataManager.loadVideoFeedResponse()
        
        // Then
        #expect(!videos.isEmpty)
        #expect(videos.count == 5) // Based on video_feed_mock.json
        
        // Verify first video structure
        let firstVideo = videos.first!
        #expect(firstVideo.id == "100")
        #expect(firstVideo.creator.name == "John Doe")
        #expect(firstVideo.likes == 1234)
        #expect(firstVideo.comments == 89)
    }

    @Test("Mock data manager should throw error for non-existent file")
    func testMockDataManagerWithInvalidFile() async throws {
        // Given
        let mockDataManager = VideoFeedMockDataManager()
        
        // When & Then
        await #expect(throws: Error.self) {
            try mockDataManager.loadVideoFeedResponse(fileName: "non_existent_file")
        }
    }

    // MARK: - Use Case Tests
    @Test("Use case should fetch and map videos successfully")
    func testFetchVideoFeedUseCaseSuccess() async throws {
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
        let videos = try await useCase.fetchVideoFeed()
        
        // Then
        #expect(videos.count == 1)
        let video = videos.first!
        #expect(video.id == "video1")
        #expect(video.creator.name == "Test User")
        #expect(video.likeCount == 100)
        #expect(video.commentCount == 10)
    }

    @Test("Use case should propagate API errors")
    func testFetchVideoFeedUseCaseError() async throws {
        // Given
        let mockService = MockVideoFeedAPIService()
        mockService.shouldThrowError = true
        
        let useCase = FetchVideoFeedUseCase(service: mockService)
        
        // When & Then
        await #expect(throws: Error.self) {
            try await useCase.fetchVideoFeed()
        }
    }

    // MARK: - API Service Tests
    @Test("VideoFeedAPIService should fetch videos in mock environment")
    func testVideoFeedAPIServiceInMockEnvironment() async throws {
        // Given
        let mockConfig = APIConfiguration(environment: .mock, baseURL: "test", simulatedDelay: 0.0)
        let mockDataManager = VideoFeedMockDataManager()
        let service = VideoFeedAPIService(
            config: mockConfig,
            mockDataManager: mockDataManager
        )
        
        // When
        let videos = try await service.fetchVideoFeed()
        
        // Then
        #expect(!videos.isEmpty)
        #expect(videos.count == 5)
        
        // Verify first video
        let firstVideo = videos.first!
        #expect(firstVideo.id == "100")
        #expect(firstVideo.creator.name == "John Doe")
    }

    @Test("VideoFeedAPIService should handle simulated delay")
    func testVideoFeedAPIServiceWithDelay() async throws {
        // Given
        let mockConfig = APIConfiguration(environment: .mock, baseURL: "test", simulatedDelay: 0.1)
        let mockDataManager = VideoFeedMockDataManager()
        let service = VideoFeedAPIService(
            config: mockConfig,
            mockDataManager: mockDataManager
        )
        
        // When
        let startTime = Date()
        let videos = try await service.fetchVideoFeed()
        let endTime = Date()
        
        // Then
        #expect(!videos.isEmpty)
        let duration = endTime.timeIntervalSince(startTime)
        #expect(duration >= 0.1) // Should take at least the simulated delay
    }
}
