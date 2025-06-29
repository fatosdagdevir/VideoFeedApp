import SwiftUI
import AVKit
import Combine

@MainActor
class VideoPlayerViewModel: ObservableObject {
    @Published var player: AVPlayer = AVPlayer()
    @Published var viewState: VideoPlayerView.ViewState = .loading
    
    private var cancellables = Set<AnyCancellable>()
    private let video: Video
    
    init(video: Video) {
        self.video = video
    }
    
    func loadVideo(autoPlay: Bool) {
        guard let url = URL(string: video.shortVideoURL) else {
            viewState = .error
            return
        }
        
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        
        Task {
            await observeStatus(of: item, autoPlay: autoPlay)
        }
    }
    
    func loadIfNeeded(autoPlay: Bool) {
        if viewState == .loading {
            loadVideo(autoPlay: autoPlay)
        }
    }
    
    func setPlayback(isPlaying: Bool) {
        isPlaying ? player.play() : player.pause()
    }
    
    private func observeStatus(of item: AVPlayerItem, autoPlay: Bool) async {
        guard let playerItem = player.currentItem else {
            viewState = .error
            return
        }
        
        while playerItem.status == .unknown {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        
        item.publisher(for: \.status)
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .readyToPlay:
                    self.viewState = .playing
                    if autoPlay {
                        self.player.play()
                    }
                case .failed, .unknown:
                    self.viewState = .error
                @unknown default:
                    self.viewState = .error
                }
            }
            .store(in: &cancellables)
    }
}
