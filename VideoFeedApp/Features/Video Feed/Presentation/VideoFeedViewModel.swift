import Foundation

@MainActor
final class VideoFeedViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var viewState: VideoFeedView.ViewState = .loading
    
    // MARK: - Private Properties
    private let navigator: Navigating
    private let fetchVideosUseCase: FetchVideoFeedUseCase
    private var lastVideoId: String?
    private var nextCursor: String?
    private var allVideos: [Video] = []
    private let videoBatchLimit = 5 // Limit is 5 instead of 20 because couldn't find lots of videos
    
    // MARK: - Public Properties
    var nextPageAvailable: Bool {
        guard let nextCursor, !nextCursor.isEmpty else {
            return false
        }
        return true
    }
        
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
            let (videos, newCursor) = try await fetchVideosUseCase.fetchVideoFeed(cursor: nextCursor, limit: videoBatchLimit)
            self.allVideos.append(contentsOf: videos)
            
            if allVideos.isEmpty {
                viewState = .empty
            } else {
                viewState = .ready(videos: allVideos)
                self.nextCursor = newCursor
            }
        } catch {
            handleError(error)
        }
    }
    
    func loadMore() async {
        if nextPageAvailable {
           await loadVideoFeed()
        }
    }
    
    func refresh() async {
        viewState = .loading
        allVideos.removeAll()
        nextCursor = nil
        
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
