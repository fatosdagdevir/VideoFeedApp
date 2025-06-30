# VideoFeedApp 📱

A modern iOS video feed application built with SwiftUI that provides a TikTok-like experience with smooth video playback, infinite scrolling, and a clean user interface.

## 🎯 Features

- **Vertical Video Feed**: Smooth scrolling through videos with paging behavior
- **Auto-Play Videos**: Videos automatically play when they become visible (50% threshold)
- **Infinite Scrolling**: Load more videos as you scroll to the bottom
- **Creator Profiles**: Display creator avatars and names
- **Video Interactions**: Like and comment functionality (UI ready)
- **Error Handling**: Graceful error states with retry capabilities
- **Loading States**: Smooth loading indicators and empty states
- **Responsive Design**: Adapts to different screen sizes and orientations

## 🏗️ Architecture

The app follows **MVVMC (Model-View-ViewModel-Coordinator)** architecture with Clean Architecture principles for a clear separation of concerns:

### MVVMC Pattern

- **Model**: Domain objects and data models
- **View**: SwiftUI views for UI presentation
- **ViewModel**: Business logic and state management
- **Coordinator**: Navigation and flow control

### Project Structure

```
VideoFeedApp/
├── App/                    # App entry point and root configuration
├── Core/                   # Core infrastructure
│   ├── Constants/         # App-wide constants
│   ├── DI/               # Dependency injection container
│   ├── Navigating/       # Navigation protocols and coordinator base
│   └── Services/         # API and data services
├── Features/             # Feature modules
│   └── Video Feed/       # Video feed feature
│       ├── Domain/       # Business logic and models
│       └── Presentation/ # UI layer (Views, ViewModels, Coordinators)
├── Resources/            # Assets and mock data
├── Shared/              # Reusable components
│   ├── Extensions/      # Swift extensions
│   └── Views/          # Shared UI components
├── Packages/            # Modular packages
│   └── Networking/      # Networking layer package
└── Tests/              # Test suite
```

### Architecture Layers

1. **Presentation Layer**: SwiftUI Views, ViewModels, and Coordinators
2. **Domain Layer**: Use Cases and Domain Models
3. **Data Layer**: API Services and Data Transfer Objects (DTOs)

## 📦 Package Dependencies

The app uses a modular approach with custom Swift packages for better maintainability and reusability:

### Networking Package

A custom networking layer that provides a clean, protocol-based approach to HTTP requests:

```swift
// Request protocol for type-safe API calls
public protocol RequestProtocol {
    associatedtype Response: Decodable
    associatedtype Body: Encodable = EmptyResponse
    
    var endpoint: any EndpointProtocol { get }
    var method: HTTP.Method { get }
    var headers: [String: String] { get }
    var body: Body? { get }
}

// Network client with async/await support
public protocol Networking {
    var decoder: JSONDecoder { get }
    var encoder: JSONEncoder { get }
    
    func data(for request: some RequestProtocol) async throws -> (Data, URLResponse)
}
```

#### Features:
- **Protocol-Based**: Type-safe request/response handling
- **Async/Await**: Modern concurrency support
- **Error Handling**: Comprehensive error types and handling
- **Modular**: Can be used across different projects
- **Testable**: Easy to mock for unit testing

#### Usage Example:
```swift
// Define API request
struct VideoFeedRequest: RequestProtocol {
    typealias Response = VideoFeedResponse
    typealias Body = EmptyResponse
    
    var endpoint: any EndpointProtocol {
        Endpoint(path: "/videos", queryItems: ["page": "1"])
    }
    var method: HTTP.Method { .get }
}

// Use in service
let network = Network()
let videos = try await network.send(request: VideoFeedRequest())
```

### Modular Benefits

- **Reusability**: Networking package can be shared across multiple projects
- **Maintainability**: Isolated concerns make debugging easier
- **Testability**: Each module can be tested independently
- **Scalability**: Easy to add new packages for different concerns

## 🚀 Getting Started

### Prerequisites

- Xcode 15.0 or later
- iOS 17.0 or later
- Swift 5.9 or later

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd VideoFeedApp
```

2. Open the project in Xcode:
```bash
open VideoFeedApp.xcodeproj
```

3. Build and run the project:
   - Select your target device or simulator
   - Press `Cmd + R` or click the Run button

### Configuration

The app is configured to use mock data by default. To switch to real API:

1. Update `AppConstants.swift` with your API base URL
2. Configure the `VideoFeedAPIService` with your API endpoints
3. Update the dependency injection container if needed

## 🧪 Testing

The project includes test coverage:

```bash
# Run all tests
Cmd + U

# Run specific test classes
# Navigate to test files and use the diamond button next to class names
```

### Test Coverage

- **Unit Tests**: ViewModels, Use Cases, Services
- **Mock Tests**: API service mocking


## 🔧 Things to Improve with More Time

1. **Image Caching & Performance**: Add caching for images so they don't reload every time. Use NSCache for quick access and save to disk for when the app restarts. Load images only when needed and preload some images ahead of time.

2. **Move Core & Reusable Views to Package**: Extract shared components like ErrorView, NetworkImageView, and common extensions into their own package for better reusability across projects.

3. **Networking Package Unit Tests**: Add comprehensive unit tests for the Networking package to ensure all network operations, error handling, and request/response parsing work correctly.

4. **Architecture Review**: I always used MVVM-C with UIKit applications and tried to adopt it to SwiftUI application but I might need to give a more careful thought since navigation is tightly coupled with views in SwiftUI.

5. **Enhancements**: Some enhancements were left out due to time constraints. With more time, I would continue refining performance and user experience throughout the app.

5. **AVKit Improvements & Best Practices**: As this was my first time working with the AVKit API, I would conduct a deeper investigation into performance tuning and best practices to improve video playback reliability and responsiveness.

6. **Pagination Batch Size**: While the requirement states that videos should be fetched in batches of 20, the current implementation uses a batch size of 5. This was done intentionally to make pagination testing and debugging easier during development. You can adjust the batch size by modifying the limit parameter in the data source or network request logic.

---
