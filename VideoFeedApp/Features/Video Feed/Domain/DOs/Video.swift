import Foundation

// MARK: - Video Domain Model
struct Video: Identifiable {
    let id: String
    let creator: Creator
    let shortVideoURL: String
    let fullVideoURL: String?
    let caption: String
    let likeCount: Int
    let commentCount: Int
}
