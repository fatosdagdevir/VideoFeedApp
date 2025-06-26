import SwiftUI

struct VideoFeedView: View {
    @ObservedObject var viewModel: VideoFeedViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            await viewModel.loadVideoFeed()
        }
    }
}

#Preview {
    VideoFeedView(
        viewModel: .init(
            navigator: Navigator(),
            fetchVideosUseCase: FetchVideoFeedUseCase(service: VideoFeedAPIService())
        )
    )
}
