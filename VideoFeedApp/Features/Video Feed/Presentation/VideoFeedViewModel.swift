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
    
    // MARK: - Public Properties
    var nextPageAvailable: Bool {
        if let nextCursor, nextCursor.isEmpty {
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
            let (videos, newCursor) = try await fetchVideosUseCase.fetchVideoFeed(cursor: nextCursor, limit: 5)
            viewState = .ready(videos: videos)
            self.allVideos.append(contentsOf: videos)
            self.nextCursor = newCursor
            
            print("nextCursor: \(nextCursor) new video count: \(videos.count) video count: \(allVideos.count)")
        } catch {
            handleError(error)
        }
    }
    
    func loadMore() async {
        print("LOAD MORE...")
        if nextPageAvailable {
           await loadVideoFeed()
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
