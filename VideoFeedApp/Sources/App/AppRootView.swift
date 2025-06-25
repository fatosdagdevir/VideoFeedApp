import SwiftUI

struct AppRootView: View {
    var body: some View {
        NavigationStack {
            ContentView()
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    AppRootView()
} 