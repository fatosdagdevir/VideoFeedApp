import SwiftUI

struct VideoFeedCoordinator: View {
    @ObservedObject var navigator: Navigator

    @StateObject private var viewModel: VideoFeedViewModel
    
    init(
        navigator: Navigator
    ) {
        self.navigator = navigator
        self._viewModel = StateObject(wrappedValue: VideoFeedViewModel(
            navigator: navigator
        ))
    }
    
    var body: some View {
        VideoFeedView(viewModel: viewModel)
    }
}

