import SwiftUI
import AVKit

struct VideoPlayerView: View {
    @Bindable var viewModel: VideoPlayerViewModel
    let coordinator: VideoPlayerCoordinator
    
    init(viewModel: VideoPlayerViewModel, coordinator: VideoPlayerCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }
    
    var body: some View {
        ZStack {
            // Placeholder for video player implementation
            Rectangle()
                .fill(.black)
                .aspectRatio(9/16, contentMode: .fit)
                .overlay {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        VStack {
                            Image(systemName: "play.circle")
                                .font(.system(size: 60))
                                .foregroundStyle(.white.opacity(0.8))
                            
                            Text("Video Player")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }
        }
        .onAppear {
            coordinator.viewDidAppear(for: viewModel)
        }
        .onDisappear {
            coordinator.viewDidDisappear(for: viewModel)
        }
    }
}

#Preview {
    VideoPlayerView(
        viewModel: VideoPlayerViewModel(videoURL: URL(string: "https://example.com/video.mp4")!),
        coordinator: VideoPlayerCoordinator()
    )
} 