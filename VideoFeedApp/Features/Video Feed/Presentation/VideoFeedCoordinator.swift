import SwiftUI

struct VideoFeedCoordinator: View {
    @ObservedObject var navigator: Navigator

    @StateObject private var viewModel: VideoFeedViewModel
    
    init(
        navigator: Navigator,
        apiService: VideoFeedAPIServiceProtocol
    ) {
        self.navigator = navigator
        self._viewModel = StateObject(wrappedValue: VideoFeedViewModel(
            navigator: navigator,
            fetchVideosUseCase: FetchVideoFeedUseCase(service: apiService)
        ))
    }
    
    var body: some View {
        VideoFeedView(viewModel: viewModel)
    }
}

