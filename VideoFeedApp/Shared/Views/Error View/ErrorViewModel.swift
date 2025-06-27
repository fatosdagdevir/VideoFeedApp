import Foundation
import Combine

final class ErrorViewModel: ObservableObject {
    private enum ErrorType: Equatable {
        case offline
        case generic
    }
    
    typealias ActionHandler = @MainActor () async -> Void
    
    let action: ActionHandler
    let error: Error
    private let type: ErrorType
    
    var headerText: String {
        switch type {
        case .offline:
            "You are offline!"
        case .generic:
            "Oops!"
        }
    }
    
    var descriptionText: String {
        switch type {
        case .offline:
            "Please check your internet connection and try again."
        case .generic:
            "Something wrong happened try again."
        }
    }
    
    var buttonTitle: String { "Retry" }
    
    init(
        error: Error,
        action: @escaping ActionHandler
    ) {
        self.error = error
        self.action = action
        if error.isOfflineError {
            self.type = .offline
        } else {
            self.type = .generic
        }
    }
}

extension ErrorViewModel: Equatable {
    static func == (lhs: ErrorViewModel, rhs: ErrorViewModel) -> Bool {
        lhs.type == rhs.type &&
        lhs.headerText == rhs.headerText &&
        lhs.descriptionText == rhs.descriptionText &&
        lhs.buttonTitle == rhs.buttonTitle
    }
}

extension Error {
    var isOfflineError: Bool {
        guard let urlError = self as? URLError else { return false }

        let offlineCodes: [URLError.Code] = [
            .notConnectedToInternet,
            .networkConnectionLost,
            .dataNotAllowed,
            .internationalRoamingOff,
            .timedOut
        ]

        return offlineCodes.contains(urlError.code)
    }
}

