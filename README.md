# Architecture

An experimental SwiftUI project for comparing common app architectures and building toward a modular MVVM design.

## Current architecture

The implemented example uses **MVVM + protocol-based interactors + a shared core interactor + dependency injection**.

![Architecture overview](docs/architecture-diagram.jpg)

### Request flow

```text
SwiftUI View
    ↓ observes and triggers
ViewModel
    ↓ depends on a feature protocol
Feature Interactor Protocol
    ↓ implemented by
CoreInteractor
    ↓ delegates to
DataManager / UserManager
    ↓ depends on
DataService
    ↓ implemented by
MockDataService (currently backed by dummyjson.com)
```

For the product screen, the flow is:

1. `ContentView` starts `ContentViewModel.loadData()` from `.task`.
2. `ContentViewModel` asks `ContentViewModelInteractor` for the user and products.
3. `CoreInteractor` conforms to the feature protocol and forwards those requests to `UserManager` and `DataManager`.
4. `DataManager` calls the injected `DataService` implementation.
5. The view model publishes the resulting products, and SwiftUI updates the view.

`HomeView` follows the same shape using `HomeViewModelInteractor`, while sharing the same `CoreInteractor` implementation.

## Responsibilities

| Layer | Responsibility | Project example |
| --- | --- | --- |
| View | Renders state and starts user-driven work | `ContentView`, `HomeView` |
| View model | Owns screen state and presentation-facing loading logic | `ContentViewModel`, `HomeViewModel` |
| Interactor protocol | Defines the capabilities required by one feature | `ContentViewModelInteractor`, `HomeViewModelInteractor` |
| Core interactor | Shares cross-feature orchestration and delegates work | `CoreInteractor` |
| Manager | Owns reusable application/data operations | `DataManager`, `UserManager` |
| Service | Provides an external data boundary that can be replaced | `DataService`, `MockDataService` |
| Container | Registers and resolves app dependencies | `DependenciesContainer` |

## Dependency injection

`DependenciesContainer` registers concrete dependencies and resolves them when `CoreInteractor` is created. The preview demonstrates the composition root:

```swift
let container = DependenciesContainer()
container.register(DataManager.self, service: DataManager(service: MockDataService()))
container.register(UserManager.self, service: UserManager())

ContentView(
    viewModel: ContentViewModel(
        interactor: CoreInteractor(container: container)
    )
)
```

Because view models depend on protocols, tests can provide a small fake interactor without making network calls. The commented `MockContentViewModelInteractor` and `ProductionHomeViewModelInteractor` show the intended production/test composition points.

## Routing

`ProfileView` is a separate routing demonstration built on the `CustomRouting` Swift Package. It exercises push navigation, sheets, full-screen covers, alerts, confirmation dialogs, custom modal presentation, and dismissal.

The routing package is intentionally kept separate from the MVVM data flow. A routed view can still use the same view model/interactor composition described above.

## Architecture evolution

The project notes the trade-offs of several approaches:

1. **No architecture** — the view owns data and business logic.
2. **MV** — a shared data manager owns most application logic.
3. **MVC** — a controller/data manager is introduced, but can become oversized.
4. **MVVM** — view models own screen state and business logic.
5. **MVVM + dependency injection** — construction and replacement of dependencies are centralized.
6. **MVVM + protocols** — view models depend on feature capabilities instead of concrete services.
7. **Shared core interactor** — common manager access is implemented once for multiple features.
8. **Core builder/composition** — dependencies and destinations can be assembled outside the views.

The current source primarily demonstrates step 7, with `DependenciesContainer` covering the composition concerns from steps 5 and 8.

## Project structure

```text
Architecture/
├── ArchitectureApp.swift       # SwiftUI app entry point
├── Core/
│   ├── ContentView.swift       # MVVM, interactors, managers, DI container, previews
│   └── ProfileView.swift       # CustomRouting examples
├── Helpers/
│   └── Helpers.swift           # Product models and DataService implementation
└── Assets.xcassets/
docs/
└── architecture-diagram.jpg   # Architecture overview
```

## Notes

- The app entry point currently has `ContentView()` commented out, so the sample screen is composed in previews rather than launched by the app window.
- `MockDataService` is named as a mock, but currently performs a real request to `https://dummyjson.com/products`; a true test double should return deterministic in-memory data.
- Errors are currently printed from the view models. A production implementation would expose loading and error state to the views.
- The project uses Swift 6 mode and the Observation framework’s `@Observable` macro.

## Requirements

- Xcode 26 or later
- iOS 26.5 deployment target (as configured in the project)
- Swift 6

Open `Architecture.xcodeproj` in Xcode to build and run the project.
