import SwiftUI

struct VideoFeedAvatarView: View {
    private enum Layout {
        static let imageSize: CGFloat = 40
        static let nameFontSize: CGFloat = 16
        static let hPadding: CGFloat = 16
    }
    
    let avatarURL: String?
    let createrName: String
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: avatarURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: Layout.imageSize, height: Layout.imageSize)
            .clipShape(Circle())
            
            Text(createrName)
                .font(.system(size: Layout.nameFontSize, weight: .semibold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.8), radius: 1)
            
            Spacer()
        }
        .padding(.horizontal, Layout.hPadding)
    }
}

#Preview {
    VideoFeedAvatarView(avatarURL: "", createrName: "julia-explorer")
}
