# MovieNight - Claude Code Guide

## Project Overview

iOS native app for discovering, rating, organizing, and sharing movies and TV shows. Built with SwiftUI and The Composable Architecture (TCA).

## Tech Stack

- **Swift 6.2+** / **SwiftUI**
- **The Composable Architecture (TCA)** 1.20.2+ - State management
- **Core Data** - Local persistence
- **TMDB API** - Movie/TV data source
- **Tuist** - Project generation

## Build Commands

```bash
# Generate Xcode project
tuist generate

# Open workspace
open App.xcworkspace

# Run tests
xcodebuild test -scheme App -destination 'generic/platform=iOS Simulator'
```

## Project Structure

```
MovieNight/
├── App/                    # Main iOS app target
│   ├── Sources/
│   │   ├── App/           # Root TCA feature (AppFeature.swift)
│   │   ├── Home/          # Home tab
│   │   ├── Library/       # Library/Collections tab
│   │   └── UpNextTab/     # Watch Later tab
│   └── Tests/             # Unit tests
├── Frameworks/
│   ├── Networking/        # HTTP client, TMDB endpoints, MovieProvider
│   ├── Models/            # Data models, API responses
│   ├── Search/            # Search feature (TCA reducer)
│   ├── UI/                # Shared SwiftUI components
│   └── Logger/            # OSLog wrapper dependency
└── CoreData/              # Core Data models
```

## Key Patterns

### TCA Architecture
- Reducers: `@Reducer` macro with `@ObservableState`
- Actions: `ViewAction` pattern with nested enums (`case view(View)`, `case api(Api)`)
- Dependencies: `@Dependency` for NetworkClient, Logger, MovieProvider
- Effects: `async/await` with `.run`, cancellation via `CancelID`

### Naming Conventions
- Reducers: `*Feature.swift`
- Views: `*Screen.swift` or `*View.swift`
- Endpoints: `*Endpoint.swift`
- API models: `*Response.swift`

### Networking
- `EndpointProviding` protocol for API endpoints
- Two sources: TMDB (content) and AWS (images)
- `NetworkClient` dependency for requests

## Important Files

| File | Purpose |
|------|---------|
| `AppFeature.swift` | Root TCA reducer, tab management |
| `NetworkClient.swift` | HTTP abstraction |
| `MovieProvider.swift` | Core Data + API coordination |
| `APIKey.swift` | TMDB API key (GITIGNORED) |

## Framework Dependencies

```
App → Search, UI, Networking, Models, Logger
Search → UI, Networking, Models, Logger
UI → Networking, Models, Logger
Networking → Models, Logger
```

## Notes

- **API Keys**: `APIKey.swift` must be created locally with TMDB credentials
- **Minimum iOS**: 26.0+
