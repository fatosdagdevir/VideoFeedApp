import SwiftUI

struct VideoFeedActionView: View {
    private enum Layout {
        enum ActionButton {
            static let size: CGFloat = 20
            static let itemSpacing: CGFloat = 20
            static let spacing: CGFloat = 6
            static let fontSize: CGFloat = 10
            static let hPadding: CGFloat = 16
            static let vPadding: CGFloat = 8
        }
    }
    
    let likeCount: Int
    let commentCount: Int
    let onLike: () -> Void
    let onComment: () -> Void
    let onShare: () -> Void

    var body: some View {
        VStack(spacing: Layout.ActionButton.itemSpacing) {
            // Like button
            actionButton(
                systemImage: "heart.fill",
                label: "\(likeCount)",
                action: onLike
            )
            // Comment button
            actionButton(
                systemImage: "message.fill",
                label: "\(commentCount)",
                action: onComment
            )
            // Share button
            actionButton(
                systemImage: "arrowshape.turn.up.right.fill",
                label: "Share",
                action: onShare
            )
        }
    }
    
    func actionButton(systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: Layout.ActionButton.spacing) {
            Button(action: action) {
                Image(systemName: systemImage)
                    .font(.system(size: Layout.ActionButton.size, weight: .medium))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.8), radius: 1)
            }
            Text(label)
                .font(.system(size: Layout.ActionButton.fontSize, weight: .semibold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.8), radius: 1)
        }
    }
}

#Preview {
    VideoFeedActionView(
        likeCount: 30,
        commentCount: 7,
        onLike: {},
        onComment: {},
        onShare: {}
    )
}
