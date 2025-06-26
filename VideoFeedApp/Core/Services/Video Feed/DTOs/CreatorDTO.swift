import Foundation

struct CreatorDTO: Codable {
    let id: String
    let name: String
    let avatarURL: String

    var mapped: Creator {
        .init(
            id: id,
            name: name,
            avatarURL: avatarURL
        )
    }
}
