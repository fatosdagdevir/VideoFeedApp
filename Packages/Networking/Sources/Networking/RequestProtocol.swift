import Foundation

public protocol RequestProtocol {
    associatedtype Response: Decodable
    associatedtype Body: Encodable = EmptyResponse
    
    var endpoint: any EndpointProtocol { get }
    var method: HTTP.Method { get }
    var headers: [String: String] { get }
    var body: Body? { get }
}

public extension RequestProtocol {
    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
    
    var body: EmptyResponse? { nil }
}
