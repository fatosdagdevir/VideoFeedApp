import Foundation

public protocol EndpointProtocol {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
}

public extension EndpointProtocol {
    var scheme: String { "https" }
    var queryItems: [URLQueryItem]? { nil }
}
