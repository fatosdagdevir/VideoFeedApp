import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let video: Video
    let isCurrentVideo: Bool
    @StateObject private var viewModel: VideoPlayerViewModel
    
    init(video: Video, isCurrentVideo: Bool) {
        self.video = video
        self.isCurrentVideo = isCurrentVideo
        self._viewModel = StateObject(wrappedValue: VideoPlayerViewModel(video: video))
    }
    
    var body: some View {
        ZStack {
            // Video Player
            if let player = viewModel.player, !viewModel.hasError {
                VideoPlayer(player: player)
                    .aspectRatio(contentMode: .fill)
                    .onTapGesture {
                        Task { @MainActor in
                            viewModel.toggleControls()
                        }
                    }
            } else if viewModel.hasError {
                // Error state
                VideoErrorView(
                    videoURL: video.shortVideoURL,
                    onRetry: { 
                        Task { @MainActor in
                            viewModel.setupPlayer()
                        }
                    }
                )
            } else {
                // Loading placeholder
                VideoLoadingView()
            }
        }
        .onChange(of: isCurrentVideo) { _, newValue in
            Task { @MainActor in
                if newValue {
                    viewModel.playVideo()
                } else {
                    viewModel.pauseVideo()
                }
            }
        }
        .onAppear {
            Task { @MainActor in
                viewModel.setupPlayer()
            }
        }
        .onDisappear {
            Task { @MainActor in
                viewModel.cleanupPlayer()
            }
        }
    }
}

// MARK: - Supporting Views

struct VideoErrorView: View {
    let videoURL: String
    let onRetry: () -> Void
    
    var body: some View {
        Color.black
            .overlay(
                VStack(spacing: 12) {
                    Text("Video unavailable")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Button("Retry") {
                        onRetry()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .clipShape(Capsule())
                }
            )
    }
}

struct VideoLoadingView: View {
    var body: some View {
        Color.black
            .overlay(
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    
                    Text("Loading video...")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
            )
    }
}

struct VideoControlsOverlay: View {
    let isPlaying: Bool
    let currentTime: Double
    let duration: Double
    let onPlayPause: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(alignment: .bottom) {
                // Left side - Play/pause and quality controls
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Button {
                            onPlayPause()
                        } label: {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 2)
                        }
                        
                        Text("Full")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Capsule())
                        
                        Spacer()
                    }
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    VideoPlayerView(
        video: Video(
            id: "1",
            creator: Creator(id: "1", name: "Test User", avatarURL: nil),
            shortVideoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            fullVideoURL: nil,
            caption: "Test video",
            likeCount: 100,
            commentCount: 10
        ),
        isCurrentVideo: true
    )
} 
