import Foundation

@MainActor
final class VideoFeedViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var viewState: VideoFeedView.ViewState = .loading
    
    // MARK: - Private Properties
    private let navigator: Navigating
    private let fetchVideosUseCase: FetchVideoFeedUseCase
    private var lastVideoId: String?
    
    init(
        navigator: Navigating,
        fetchVideosUseCase: FetchVideoFeedUseCase
    ) {
        self.navigator = navigator
        self.fetchVideosUseCase = fetchVideosUseCase
    }
    
    // MARK: - Public Methods
    func loadVideoFeed() async {
        do {
            let videos = try await fetchVideosUseCase.fetchVideoFeed()
            viewState = .ready(videos: videos)
        } catch {
            handleError(error)
        }
    }
    
    func refresh() async {
        viewState = .loading
        
        await loadVideoFeed()
    }
    
    //MARK: Private Helpers
    private func handleError(_ error: Error) {
        viewState = .error(
            viewModel: ErrorViewModel(
                error: error,
                action: {  [weak self] in
                    await self?.refresh()
                }
            )
        )
    }
}
