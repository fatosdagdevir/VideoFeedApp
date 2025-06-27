import SwiftUI
import AVKit

// MARK: - VideoFeedView
struct VideoFeedView: View {
    enum ViewState: Equatable {
        case loading
        case ready(videos: [Video])
        case error(viewModel: ErrorViewModel)
    }
    
    private enum Layout {
        static let vSpacing: CGFloat = 12
        static let captionFontSize: CGFloat = 12
        static let captionHSpacing: CGFloat = 8
        static let bottomContentHPadding: CGFloat = 16
        static let captionLineLimit: Int = 3
    }
    
    @ObservedObject var viewModel: VideoFeedViewModel
    @State private var visibleIndex: Int = 0
    
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
            case .ready(let videos):
                content(videos)
            case .error(let viewModel):
                ErrorView(viewModel: viewModel)
            }
        }
        .task {
            await viewModel.loadVideoFeed()
        }
    }
    
    private func content(_ videos: [Video]) -> some View {
        GeometryReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: .zero) {
                    ForEach(Array(videos.enumerated()), id: \.offset) { index, video in
                        videoFeedItem(
                            video: video,
                            proxy: proxy,
                            isPlaying: index == visibleIndex
                        )
                        .frame(
                            width: proxy.size.width,
                            height: proxy.size.height + (proxy.safeAreaInsets.bottom / 2)
                        )
                        .background(
                            GeometryReader { innerGeo in
                                Color.clear
                                    .preference(key: VisibleIndexPreferenceKey.self, value: [
                                        index: abs(innerGeo.frame(in: .global).minY)
                                    ])
                            }
                        )
                    }
                }
                .scrollTargetLayout()
                
                Rectangle()
                    .frame(height: 100)
                    .background(Color.yellow)
                if viewModel.nextPageAvailable {
                    ProgressView()
                        .task {
                            await viewModel.loadMore()
                        }
                        .frame(maxWidth: .infinity)
                }
            }
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .background(Color.black)
            .onPreferenceChange(VisibleIndexPreferenceKey.self) { values in
                if let (index, _) = values.min(by: { $0.value < $1.value }) {
                    visibleIndex = index
                }
            }
        }
    }
    
    private func videoFeedItem(
        video: Video,
        proxy: GeometryProxy,
        isPlaying: Bool
    ) -> some View {
        ZStack {
            
            VideoPlayerView(
                video: video,
                isPlaying: isPlaying
            )
            .frame(width: proxy.size.width, height: proxy.size.height)
            
            VStack {
                
                // Top header area
                VideoFeedAvatarView(
                    avatarURL: video.creator.avatarURL,
                    createrName: video.creator.name
                )
                .padding(.top, proxy.safeAreaInsets.bottom)
                
                Spacer()
                
                // Bottom content area
                HStack(alignment: .bottom, spacing: Layout.captionHSpacing) {
                    
                    // Left side - Caption
                    caption(name: video.creator.name, caption: video.caption)
                    
                    Spacer()
                    
                    // Right side - Actions
                    VideoFeedActionView(
                        likeCount: video.likeCount,
                        commentCount: video.commentCount,
                        onLike: {},
                        onComment: {},
                        onShare: {}
                    )
                }
                .padding(.horizontal, Layout.bottomContentHPadding)
                .padding(.bottom, proxy.safeAreaInsets.top)
            }
        }
    }
    
    private func caption(name: String, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.8), radius: 1)
            
            Text(caption)
                .font(.system(size: Layout.captionFontSize, weight: .semibold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.8), radius: 1)
                .lineLimit(Layout.captionLineLimit)
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

private struct VisibleIndexPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}
