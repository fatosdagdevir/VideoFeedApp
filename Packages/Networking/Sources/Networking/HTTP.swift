import Foundation

public enum HTTP {
    public enum Method: String, CaseIterable {
        case GET
        case POST 
        case PUT
        case DELETE
    }
    
    public enum RequestHeaderKey: String {
        case contentType = "Content-Type"
        case authorization = "Authorization"
    }
}
