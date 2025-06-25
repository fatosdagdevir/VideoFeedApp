import Foundation

public enum NetworkError: LocalizedError {
    case invalidStatus(Int)
    case serverError(Int)
    case offline
    case decodingError
    case invalidURL
    case unknown
    
    public var statusCode: Int {
        switch self {
        case .invalidStatus(let code), .serverError(let code):
            return code
        case .unknown, .offline, .decodingError, .invalidURL:
            return 0
        }
    }
    
    private static let offlineCodes: Set<URLError.Code> = [
        .notConnectedToInternet,
        .networkConnectionLost,
        .dataNotAllowed,
        .internationalRoamingOff,
        .timedOut
    ]
    
    public var isOfflineError: Bool {
        switch self {
        case .offline:
            return true
        case .invalidStatus(let code):
            return code == 0 // No internet connection
        default:
            return false
        }
    }
    
    public init?(error: Error) {
        if let urlError = error as? URLError,
           Self.offlineCodes.contains(urlError.code) {
            self = .offline
        } else if error is DecodingError {
            self = .decodingError
        } else {
            self = .unknown
        }
    }
    
    public init?(response: URLResponse) {
        guard let httpResponse = response as? HTTPURLResponse else {
            return nil
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return nil
        case 500...599:
            self = .serverError(httpResponse.statusCode)
        default:
            self = .invalidStatus(httpResponse.statusCode)
        }
    }
}

public extension NetworkError {
    static func handle(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError {
            return networkError
        }
        return NetworkError(error: error) ?? .unknown
    }
}
