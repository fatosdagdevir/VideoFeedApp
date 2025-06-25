import Foundation
import AVKit

@Observable
@MainActor
final class VideoPlayerCoordinator {
    // MARK: - Initialization
    init() {
        // TODO: Initialize coordinator
    }
    
    // MARK: - Public Methods
    func viewDidAppear(for viewModel: VideoPlayerViewModel) {
        // TODO: Handle view appearance
    }
    
    func viewDidDisappear(for viewModel: VideoPlayerViewModel) {
        // TODO: Handle view disappearance
    }
}

// MARK: - VideoPlayerViewModel Hashable Conformance
extension VideoPlayerViewModel: Hashable {
    static func == (lhs: VideoPlayerViewModel, rhs: VideoPlayerViewModel) -> Bool {
        lhs.videoURL == rhs.videoURL
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(videoURL)
    }
} 