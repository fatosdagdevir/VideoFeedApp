import Foundation

// MARK: - Creator Domain Model
struct Creator: Identifiable, Equatable {
    let id: String
    let name: String
    let avatarURL: String?
}
