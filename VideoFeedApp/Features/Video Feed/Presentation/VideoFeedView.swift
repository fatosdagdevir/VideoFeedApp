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
    }
}

#Preview {
    VideoFeedView(
        viewModel: .init(navigator: Navigator())
    )
}
