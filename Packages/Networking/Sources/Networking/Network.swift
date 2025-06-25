import Foundation

public protocol Networking {
    var decoder: JSONDecoder { get }
    var encoder: JSONEncoder { get }
    
    func data(for request: some RequestProtocol) async throws -> (Data, URLResponse)
}

public extension Networking {
    func send<Request: RequestProtocol>(request: Request) async throws -> Request.Response {
        let (data, _) = try await data(for: request)
        return try decode(data: data)
    }
    
    func decode<T: Decodable>(data: Data) throws -> T {
        if T.self == EmptyResponse.self, let emptyResponse = EmptyResponse() as? T {
            return emptyResponse
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}

@available(macOS 12.0, iOS 16.0, *)
public struct Network: Networking {
    enum InternalError: Error {
        case invalidURL
    }
    
    public let encoder: JSONEncoder
    public let decoder: JSONDecoder
    let session: URLSession
    private let timeoutInterval: TimeInterval
    
    public init(
        session: URLSession = URLSession.shared,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder(),
        timeoutInterval: TimeInterval = 20.0
    ) {
        self.session = session
        self.encoder = encoder
        self.decoder = decoder
        self.timeoutInterval = timeoutInterval
    }
    
    public func data(for request: some RequestProtocol) async throws -> (Data, URLResponse) {
        guard let urlRequest = URLRequest(
            endpoint: request.endpoint,
            method: request.method,
            timeoutInterval: timeoutInterval,
            headers: request.headers
        ) else {
            throw NetworkError.invalidURL
        }
        
        var finalRequest = urlRequest
        
        if let body = request.body {
            do {
                finalRequest.httpBody = try encoder.encode(body)
            } catch {
                throw NetworkError.unknown
            }
        }
        
        do {
            let (data, response) = try await session.data(for: finalRequest)
            
            if let error = NetworkError(response: response) {
                throw error
            }
            
            return (data, response)
        } catch {
            throw NetworkError.handle(error)
        }
    }
}

public struct EmptyResponse: Codable {
    public init() {}
}
