import Foundation

struct FetchVideoFeedUseCase {
    private let service: VideoFeedAPIServiceProtocol
    
    init(service: VideoFeedAPIServiceProtocol) {
        self.service = service
    }
    
    func fetchVideoFeed() async throws -> [Video] {
        let response = try await service.fetchVideoFeed()
        return response.map { $0.mapped }
    }
}
