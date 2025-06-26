import Foundation

struct VideoDTO: Codable {
    let id: String
    let creator: CreatorDTO
    let shortVideoURL: String
    let fullVideoURL: String
    let description: String
    let likes: Int
    let comments: Int
    
    var mapped: Video {
        .init(
            id: id,
            creator: creator.mapped,
            shortVideoURL: shortVideoURL,
            fullVideoURL: fullVideoURL,
            caption: description,
            likeCount: likes,
            commentCount: comments
        )
    }
}
