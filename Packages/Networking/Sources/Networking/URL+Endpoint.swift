import Foundation

public extension URL {
    init?(endpoint: any EndpointProtocol) {
        var components = URLComponents()
        components.scheme = endpoint.scheme
        components.host = endpoint.host
        components.path = endpoint.path
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            return nil
        }
        
        self = url
    }
}
