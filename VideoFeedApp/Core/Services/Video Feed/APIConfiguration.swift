import Foundation

enum APIEnvironment {
    case production     /// Real backend API
    case mock          /// Local JSON files
}

struct APIConfiguration {
    let environment: APIEnvironment
    let baseURL: String
    let simulatedDelay: TimeInterval
    
    static let current: APIConfiguration = {
        #if DEBUG
        // Mock data
        return APIConfiguration(
            environment: .mock,
            baseURL: "https://api.example.com",
            simulatedDelay: 1.0
        )
        #else
        // Real API
        return APIConfiguration(
            environment: .production,
            baseURL: "https://api.yourapp.com",
            simulatedDelay: 0.0
        )
        #endif
    }()
}
