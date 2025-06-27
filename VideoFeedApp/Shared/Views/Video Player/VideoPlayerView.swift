import SwiftUI
import AVKit

struct VideoPlayerView: View {
    enum ViewState: Equatable {
        case loading
        case playing
        case error
    }
    
    private enum Layout {
        enum ErrorView {
            static let vSpacing: CGFloat = 12
            static let buttonHPadding: CGFloat = 16
            static let buttonVPadding: CGFloat = 8
        }
    }
    
    let video: Video
    let isCurrentVideo: Bool
    @StateObject private var viewModel: VideoPlayerViewModel
    
    init(video: Video, isCurrentVideo: Bool) {
        self.video = video
        self.isCurrentVideo = isCurrentVideo
        self._viewModel = StateObject(wrappedValue: VideoPlayerViewModel(video: video))
    }
    
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                loadingView
            case .playing:
                player
            case .error:
                errorView
            }
        }
        .onAppear {
            Task { @MainActor in
                viewModel.setupPlayer()
            }
        }
    }
    
    private var player: some View {
        Group {
            if let player = viewModel.player {
                VideoPlayer(player: player)
                    .aspectRatio(contentMode: .fill)
            }
        }
    }
    
    private var loadingView: some View {
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
    
    private var errorView: some View {
        Color.black
            .overlay(
                VStack(spacing: Layout.ErrorView.vSpacing) {
                    Text("Video unavailable")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Button("Retry") {
                        Task { @MainActor in
                            viewModel.setupPlayer()
                        }
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, Layout.ErrorView.buttonHPadding)
                    .padding(.vertical, Layout.ErrorView.buttonVPadding)
                    .background(Color.white)
                    .clipShape(Capsule())
                }
            )
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
