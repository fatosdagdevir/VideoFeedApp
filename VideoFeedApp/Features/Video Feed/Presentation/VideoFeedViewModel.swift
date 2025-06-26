import Foundation

@MainActor
final class VideoFeedViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var videos: [Video] = []
    
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
            let result = try await fetchVideosUseCase.fetchVideoFeed()
            self.videos = result
        } catch {
            print("❌ Failed to load videos: \(error)")
        }
    }
}
