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
            #expect(true)
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
        sut.loadVideo()
        
        // Then
        if case .error = sut.viewState {
            #expect(true)
        } else {
            #expect(Bool(false), "Expected error state for invalid URL")
        }
    }
    
    @Test("SetPlayback plays and pauses the video")
    func testSetPlayback_playAndPause() async {
        // Given
        let video = Video(
            id: "3",
            creator: Creator(id: "1", name: "Tester", avatarURL: nil),
            shortVideoURL: "https://example.com/video.mp4",
            fullVideoURL: nil,
            caption: "Playback test",
            likeCount: 0,
            commentCount: 0
        )
        
        let sut = await VideoPlayerViewModel(video: video)
        
        // When
        await sut.setPlayback(isPlaying: true)
        await #expect(sut.player.rate == 1.0)
        
        await sut.setPlayback(isPlaying: false)
        await #expect(sut.player.rate == 0.0)
    }
}
