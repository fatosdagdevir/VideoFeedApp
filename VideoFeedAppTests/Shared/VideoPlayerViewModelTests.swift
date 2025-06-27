import Testing
import AVKit
import Foundation
@testable import VideoFeedApp

struct VideoPlayerViewModelTests {
    
    @Test("VideoPlayerViewModel should initialize with loading state")
    @MainActor
    func init_withValidVideo_createsViewModelWithLoadingState() async throws {
        // Given
        let video = Video(
            id: "test_video",
            creator: Creator(id: "user1", name: "Test User", avatarURL: "https://example.com/avatar.jpg"),
            shortVideoURL: "https://example.com/video.mp4",
            fullVideoURL: nil,
            caption: "Test video",
            likeCount: 100,
            commentCount: 10
        )
        
        // When
        let sut = VideoPlayerViewModel(video: video)
        
        // Then
        if case .loading = sut.viewState {
            // Success
        } else {
            #expect(Bool(false), "Expected loading state")
        }
        #expect(sut.player == nil)
    }
    
    @Test("VideoPlayerViewModel should create player when playing is true")
    @MainActor
    func setupPlayer_withValidURL_createsAVPlayer() async throws {
        // Given
        let video = Video(
            id: "test_video",
            creator: Creator(id: "user1", name: "Test User", avatarURL: "https://example.com/avatar.jpg"),
            shortVideoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            fullVideoURL: nil,
            caption: "Test video",
            likeCount: 100,
            commentCount: 10
        )
        
        let sut = VideoPlayerViewModel(video: video)
        
        // When
        sut.setupPlayer()
        
        // Then
        #expect(sut.player != nil)
        #expect(sut.player?.currentItem != nil)
        // Video loading is async, so initially it will be in loading state
        if case .loading = sut.viewState {
            // Success
        } else {
            #expect(Bool(false), "Expected loading state")
        }
    }
    
    @Test("VideoPlayerViewModel should handle invalid video URL")
    @MainActor
    func setupPlayer_withInvalidURL_setsErrorState() async throws {
        // Given
        let video = Video(
            id: "test_video",
            creator: Creator(id: "user1", name: "Test User", avatarURL: "https://example.com/avatar.jpg"),
            shortVideoURL: "",
            fullVideoURL: nil,
            caption: "Test video",
            likeCount: 100,
            commentCount: 10
        )
        
        let sut = VideoPlayerViewModel(video: video)
        
        // When
        sut.setupPlayer()
        
        // Then
        if case .error = sut.viewState {
            // Success
        } else {
            #expect(Bool(false), "Expected error state for invalid URL")
        }
    }
    
    @Test("VideoPlayerViewModel should not create player when not playing")
    @MainActor
    func init_withIsPlayingFalse_doesNotCreatePlayer() async throws {
        // Given
        let video = Video(
            id: "test_video",
            creator: Creator(id: "user1", name: "Test User", avatarURL: "https://example.com/avatar.jpg"),
            shortVideoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            fullVideoURL: nil,
            caption: "Test video",
            likeCount: 100,
            commentCount: 10
        )
        
        // When
        let sut = VideoPlayerViewModel(video: video)
        
        // Then
        #expect(sut.player == nil)
        if case .loading = sut.viewState {
            // Success
        } else {
            #expect(Bool(false), "Expected loading state")
        }
    }

    
    @Test("VideoPlayerViewModel should handle multiple setup calls safely")
    @MainActor
    func setupPlayer_calledMultipleTimes_handlesGracefully() async throws {
        // Given
        let video = Video(
            id: "test_video",
            creator: Creator(id: "user1", name: "Test User", avatarURL: "https://example.com/avatar.jpg"),
            shortVideoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            fullVideoURL: nil,
            caption: "Test video",
            likeCount: 100,
            commentCount: 10
        )
        
        let sut = VideoPlayerViewModel(video: video)
        
        // When
        sut.setupPlayer()
        let firstPlayer = sut.player
        sut.setupPlayer()
        let secondPlayer = sut.player
        
        // Then
        #expect(firstPlayer != nil)
        #expect(secondPlayer != nil)
        // Should handle multiple calls without crashing
        // Initially will be in loading state
        if case .loading = sut.viewState {
            // Success
        } else {
            #expect(Bool(false), "Expected loading state")
        }
    }
} 
