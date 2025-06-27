import Testing
import Foundation
@testable import VideoFeedApp

struct ErrorViewModelTests {
    
    @Test("ErrorViewModel should initialize with error and action")
    func init_withErrorAndAction_createsViewModel() async throws {
        // Given
        let expectedError = URLError(.networkConnectionLost)
        var actionCalled = false
        let action: () async -> Void = {
            actionCalled = true
        }
        
        // When
        let sut = ErrorViewModel(error: expectedError, action: action)
        
        // Then
        #expect(sut.headerText == "You are offline!")
        #expect(sut.descriptionText.contains("internet"))
        #expect(sut.buttonTitle == "Retry")
        
        // Test action
        await sut.action()
        #expect(actionCalled == true)
    }
    
    @Test("ErrorViewModel should handle different error types")
    func init_withDifferentErrors_providesCorrectMessages() async throws {
        // Given
        let networkError = URLError(.networkConnectionLost)
        let timeoutError = URLError(.timedOut)
        let unknownError = URLError(.unknown)
        
        // When
        let networkErrorVM = ErrorViewModel(error: networkError, action: {})
        let timeoutErrorVM = ErrorViewModel(error: timeoutError, action: {})
        let unknownErrorVM = ErrorViewModel(error: unknownError, action: {})
        
        // Then
        #expect(networkErrorVM.headerText == "You are offline!")
        #expect(timeoutErrorVM.headerText == "You are offline!")
        #expect(unknownErrorVM.headerText == "Oops!")
        
        #expect(networkErrorVM.descriptionText.contains("internet"))
        #expect(timeoutErrorVM.descriptionText.contains("internet"))
        #expect(unknownErrorVM.descriptionText.contains("try again"))
    }
} 
