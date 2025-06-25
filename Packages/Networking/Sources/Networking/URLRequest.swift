import Foundation

public extension URLRequest {
    init?(
        endpoint: any EndpointProtocol,
        method: HTTP.Method,
        timeoutInterval: TimeInterval = 20.0,
        headers: [String: String] = [:]
    ) {
        guard let url = URL(endpoint: endpoint) else {
            return nil
        }
        
        self.init(url: url, timeoutInterval: timeoutInterval)
        httpMethod = method.rawValue
        
        for (key, value) in headers {
            setValue(value, forHTTPHeaderField: key)
        }
    }
}
