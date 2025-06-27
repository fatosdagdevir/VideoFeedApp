import SwiftUI
import AVKit
import Combine

@MainActor
class VideoPlayerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var player: AVPlayer?
    @Published var viewState: VideoPlayerView.ViewState = .loading
    
    // MARK: - Private Properties
    private  var isError: Bool {
        if case .error = viewState { return true }
        return false
    }
    private let video: Video
    private var cancellables = Set<AnyCancellable>()
    
    init(video: Video) {
        self.video = video
    }
    
    // MARK: - Public Methods
    func setupPlayer() {
        Task { @MainActor in
            viewState = .loading
            
            guard let url = URL(string: video.shortVideoURL) else {
                viewState = .error
                return
            }
            
            let newPlayer = AVPlayer(url: url)
            self.player = newPlayer
            
            newPlayer.automaticallyWaitsToMinimizeStalling = false
            newPlayer.volume = 1.0
            
            await self.loadVideo()
        }
    }

    
    func playVideo() {
        guard let player = player, !isError else { return }
        
        player.play()
        viewState = .playing
    }
    
    func pauseVideo() {
        guard let player = player else { return }
        
        player.pause()
    }
    
    private func loadVideo() async {
        guard let player = player,
              let playerItem = player.currentItem else {
            viewState = .error
            return
        }
        
        while playerItem.status == .unknown {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        
        playerItem.publisher(for: \AVPlayerItem.status)
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .readyToPlay:
                    viewState = .playing
                case .failed, .unknown:
                    viewState = .error
                @unknown default:
                    viewState = .error
                }
            }
            .store(in: &cancellables)
    }
}
