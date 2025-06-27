import SwiftUI

struct VideoFeedAvatarView: View {
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
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            
            Text(createrName)
                .font(.system(size: 16.0, weight: .semibold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.8), radius: 1)
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    VideoFeedAvatarView(avatarURL: "", createrName: "julia-explorer")
}
