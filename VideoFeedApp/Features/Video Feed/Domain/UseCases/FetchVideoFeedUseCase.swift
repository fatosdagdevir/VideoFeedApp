import Foundation

struct FetchVideoFeedUseCase {
    private let service: VideoFeedAPIServiceProtocol
    
    init(service: VideoFeedAPIServiceProtocol) {
        self.service = service
    }
    
    func fetchVideoFeed(cursor: String?, limit: Int) async throws -> ([Video], String?) {
        let response = try await service.fetchVideoFeed(cursor: cursor, limit: limit)
        return (response.0.map { $0.mapped }, response.1)
    }
}
