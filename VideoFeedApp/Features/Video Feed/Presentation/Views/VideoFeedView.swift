import SwiftUI
import AVKit

// MARK: - VideoFeedView
struct VideoFeedView: View {
    enum ViewState: Equatable {
        case loading
        case ready(videos: [Video])
        case empty
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
    @State private var isLoadingMore: Bool = false
    @State private var playingIndices: Set<Int> = []
    
    var body: some View {
        GeometryReader { proxy in
            Group {
                switch viewModel.viewState {
                case .loading:
                    loadingView
                case .ready(let videos):
                    content(videos, proxy: proxy)
                case .empty:
                    emptyView
                case .error(let viewModel):
                    ErrorView(viewModel: viewModel)
                }
            }
            .task {
                await viewModel.loadVideoFeed()
            }
        }
    }
    
    private func content(_ videos: [Video], proxy: GeometryProxy) -> some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: .zero) {
                ForEach(Array(videos.enumerated()), id: \.offset) { index, video in
                    ZStack {
                        // Video Player
                        VideoPlayerView(
                            video: video,
                            isPlaying: Binding(
                                get: { playingIndices.contains(index) },
                                set: { shouldPlay in
                                    if shouldPlay {
                                        playingIndices.insert(index)
                                    } else {
                                        playingIndices.remove(index)
                                    }
                                }
                            )
                        )
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        
                        // Header, Caption, Action Items
                        videoOverlayItems(video: video, proxy: proxy)
                    }
                    .frame(maxWidth: .infinity)
                    .containerRelativeFrame(.vertical)
                    .background(
                        GeometryReader { innerProxy in
                            Color.clear
                                .preference(key: VideoVisibilityPreferenceKey.self, value: [
                                    index: calculateVisibilityPercentage(
                                        itemFrame: innerProxy.frame(in: .global),
                                        screenHeight: proxy.size.height
                                    )
                                ])
                        }
                    )
                }
            }
            .scrollTargetLayout()
            
            if viewModel.nextPageAvailable || isLoadingMore {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .scaleEffect(1.2)
            }
        }
        .background(.black)
        .scrollTargetBehavior(.paging)
        .onPreferenceChange(VideoVisibilityPreferenceKey.self) { values in
            // Find videos that are at least 50% visible
            let newPlayingIndices = Set(values.compactMap { (index, percentage) in
                percentage >= 0.5 ? index : nil
            })
            
            if newPlayingIndices != playingIndices {
                playingIndices = newPlayingIndices
            }
            
            // Update visibleIndex to the most visible video for pagination
            if let (index, _) = values.max(by: { $0.value < $1.value }) {
                visibleIndex = index
                
                // Trigger pagination when the last video becomes visible
                if index == videos.count - 1 && viewModel.nextPageAvailable && !isLoadingMore {
                    isLoadingMore = true
                    Task {
                        await viewModel.loadMore()
                        isLoadingMore = false
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func videoOverlayItems(
        video: Video,
        proxy: GeometryProxy
    ) -> some View {
        VStack {
            // Top header area
            VideoFeedAvatarView(
                avatarURL: video.creator.avatarURL,
                createrName: video.creator.name
            )
            .padding(.top, proxy.safeAreaInsets.top + 4)
            
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
            .padding(.bottom, proxy.safeAreaInsets.bottom + 4)
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
    
    private var loadingView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("No videos available")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func calculateVisibilityPercentage(itemFrame: CGRect, screenHeight: CGFloat) -> Double {
        let screenBounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: screenHeight)
        let intersection = itemFrame.intersection(screenBounds)
        
        guard !intersection.isNull else { return 0.0 }
        
        let visibleArea = intersection.height * intersection.width
        let totalArea = itemFrame.height * itemFrame.width
        
        return Double(visibleArea / totalArea)
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

private struct VideoVisibilityPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: Double] = [:]
    
    static func reduce(value: inout [Int: Double], nextValue: () -> [Int: Double]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}


