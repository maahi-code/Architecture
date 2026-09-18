# Architecture

An experimental SwiftUI project for comparing common app architectures and building toward a VIPER design.

## Current architecture

The current example uses a small **VIPER-style composition**, where `ContentPresenter` depends on an interactor and a router.

## Visual architecture journey

The diagrams are ordered from the least structured approach to the current VIPER design. Each stage keeps the useful parts of the previous one, then adds a boundary when the app becomes harder to understand, test, or change.

### Overview: architecture has a cost and a purpose

![Architecture spectrum: Views only, MV, MVC, and MVVM](docs/00-architecture-complexity-spectrum.jpg)

Moving from left to right adds structure. That usually improves testability, replacement of dependencies, and clarity of responsibility—but also creates more types and setup. The goal is not to use the most architecture; it is to use the smallest structure that keeps the feature understandable.

### 1. No architecture: a View calls a service

![No architecture: a View directly calls a Service](docs/01-no-architecture-simple-view-service.jpg)

At the beginning, one View calls one Service directly. For a small, temporary screen this is fast to write and easy to follow.

- The View renders the UI, starts the request, handles loading/error state, and transforms data.
- The Service performs the data request.
- There is no separate place to test business or presentation logic without creating the View.

This is a reasonable starting point. The limitation appears when the same kind of work is needed by many screens.

### 2. No architecture at scale: many Views call services directly

![No architecture at scale: Views directly depend on multiple Services](docs/02-no-architecture-direct-service-dependencies.jpg)

As the view tree grows, different Views reach directly into one or more Services. The green oval is the shared SwiftUI view hierarchy; a parent can inject values into its descendants through the **Environment**.

- Environment values are convenient shared dependencies or state for a subtree.
- They also make dependencies implicit: a View can need an object without showing that requirement in its initializer.
- When several Views use the same shared object, a change in that object can affect multiple parts of the tree.

This is the first pressure toward architecture: separate reusable work from the Views and make dependencies clearer.

### 3. MV: introduce managers for shared application and data work

![MV architecture with shared SwiftUI environment, managers, services, and models](docs/03-mv-shared-environment-managers.jpg)

MV keeps the View as the presentation layer and introduces **Managers** for reusable application and data operations. Managers call Services, and Services decode or return Models.

- **View:** renders UI and may still contain business decisions.
- **Manager:** shares data/application operations across the app.
- **Service:** owns an external boundary such as a network request, database, or SDK.
- **Model:** represents returned data.

This reduces duplicated service code, but Views can still become responsible for too much logic and can be coupled to shared manager state.

### 4. MVC: put a controller/data boundary between the View and services

![MVC architecture with a Manager between Views and Services](docs/04-mvc-manager-boundary.jpg)

This project’s SwiftUI-style MVC step introduces a manager/controller-like layer between Views and Services. Views no longer perform raw data access themselves.

- The View still owns some feature decisions and screen state.
- The manager centralizes data access and forwards work to Services.
- The split is cleaner than direct service access, but logic can accumulate in the View/controller layer as the feature grows.

That “massive controller” risk motivates MVVM.

### 5. MVVM: give each screen a ViewModel

![MVVM architecture](docs/05-mvvm-viewmodel.jpg)

Each screen receives a ViewModel. The ViewModel owns observable presentation state and coordinates managers; the View renders state and sends user events.

- **View:** UI only—render state and forward actions.
- **ViewModel:** loading, error, screen state, transformations, and feature decisions.
- **Manager/Service:** reusable application work and external data access.

This is the important turning point: presentation logic can be tested without the SwiftUI View. The next issue is that a ViewModel may still know too much about concrete managers.

### 6. MVVM + feature interactors: depend on capabilities, not concrete managers

![MVVM architecture with feature interactors](docs/06-mvvm-feature-interactor-protocols.jpg)

Each ViewModel now depends on an **Interactor** protocol that states exactly what that feature needs. The protocol can be implemented by production code or a test fake.

- A ViewModel asks for `getProducts()` rather than knowing which manager or service supplies products.
- The Interactor performs or orchestrates feature work.
- Tests can inject a small fake Interactor and avoid networking, databases, and SDKs.

This introduces more types, but dependency direction is clearer and each feature becomes easier to test in isolation.

### 7. Shared CoreInteractor: centralize common orchestration

![MVVM architecture with a shared CoreInteractor](docs/07-mvvm-shared-core-interactor.jpg)

Several feature interactors can share one `CoreInteractor` implementation. It becomes the common bridge to managers and services.

- Feature protocols keep each ViewModel’s required API small.
- `CoreInteractor` avoids repeating manager wiring in every feature.
- Managers remain reusable and Services remain replaceable.

The trade-off is scope: a `CoreInteractor` should not become a single catch-all type. Keep feature protocols narrow even if one implementation satisfies several of them.

### 8. CoreBuilder: compose dependencies and navigation outside the feature

![MVVM architecture with a CoreBuilder](docs/08-mvvm-core-builder-composition.jpg)

`CoreBuilder` is the composition root. It receives registered dependencies and creates fully configured features instead of allowing Views to construct their own collaborators.

- Dependencies are assembled in one place.
- Features receive what they need through initializers.
- Reusable UI components and destinations can be composed outside individual Views.

This removes much of the hidden Environment-based construction and prepares the project to decouple routing completely.

### 9. VIPER: separate Presenter and Router

![VIPER architecture](docs/09-viper-presenter-router.jpg)

VIPER completes this progression by giving each responsibility an explicit home:

- **View** displays observable presentation state and forwards user events.
- **Presenter** owns presentation state and coordinates the Interactor and Router.
- **Interactor** performs feature/business work.
- **Entity** is the feature’s model/domain data—for example, `Product` is both a model and an Entity here.
- **Router** owns navigation and destination creation.

The Presenter still works with the View through events and observable state. The key change is that it does not own service details or navigation details: it delegates work to the Interactor and navigation to the Router.

### Request flow

```text
View
    ↓ displays state and sends events
Presenter
    ├── requests feature work from
    │   Interactor
    │       ↓ delegates to
    │   DataManager / UserManager
    │       ↓ depends on
    │   DataService
    │       ↓ implemented by
    │   MockDataService (currently backed by dummyjson.com)
    └── requests navigation from
        Router
```

For the product screen, the flow is:

1. `ContentView` starts `ContentPresenter.loadData()` from `.task`.
2. `ContentPresenter` asks `ContentPresenterInteractor` for the user and products.
3. `CoreInteractor` conforms to the interactor protocol and forwards those requests to `UserManager` and `DataManager`.
4. `DataManager` calls the injected `DataService` implementation.
5. The presenter publishes the resulting products, and SwiftUI updates the view.
6. When a product is tapped, the presenter asks `ContentPresenterRouter` to navigate.

## Responsibilities

| Layer | Responsibility | Project example |
| --- | --- | --- |
| View | Renders state and forwards user-driven events | `ContentView` |
| Presenter | Owns presentation state, receives view events, and coordinates the interactor and router | `ContentPresenter` |
| Interactor protocol | Defines the capabilities required by the feature | `ContentPresenterInteractor` |
| Interactor | Performs feature work and delegates to managers | `CoreInteractor` |
| Router | Owns navigation and destination construction | `ContentPresenterRouter`, `CoreRouter` |
| Entity | Represents the model/domain data used by the feature | `Product` |
| Manager | Owns reusable application/data operations | `DataManager`, `UserManager` |
| Service | Provides an external data boundary that can be replaced | `DataService`, `MockDataService` |
| Container | Registers and resolves app dependencies | `DependenciesContainer` |

## Dependency injection

`DependenciesContainer` registers concrete dependencies and resolves them when `CoreInteractor` is created. The preview demonstrates the composition root:

```swift
let container = DependenciesContainer()
container.register(DataManager.self, service: DataManager(service: MockDataService()))
container.register(UserManager.self, service: UserManager())

RouterView { router in
    ContentView(
        presenter: ContentPresenter(
            interactor: CoreInteractor(container: container),
            router: CoreRouter(router: router)
        )
    )
}
```

Because the presenter depends on protocols, tests can provide small fake interactors and routers without making network calls or performing real navigation. The commented mock interactor shows the intended production/test composition point.

## Routing

`ProfileView` is a separate routing demonstration built on the `CustomRouting` Swift Package. It exercises push navigation, sheets, full-screen covers, alerts, confirmation dialogs, custom modal presentation, and dismissal.

In the VIPER-style `ContentView` example, routing is a first-class dependency of the presenter. The view reports a navigation event to the presenter, and the presenter delegates destination construction to `ContentPresenterRouter`; the view does not need to know how navigation is implemented.

## VIPER

VIPER separates a feature into **View, Interactor, Presenter, Entity, and Router**:

| VIPER part | Responsibility | Project example |
| --- | --- | --- |
| View | Displays state and forwards user events | `ContentView` |
| Interactor | Performs feature/business work | `ContentPresenterInteractor`, `CoreInteractor` |
| Presenter | Coordinates view events, presentation state, the interactor, and routing | `ContentPresenter` |
| Entity | Feature/domain model data; this is the same role commonly called a model | `Product` |
| Router | Owns navigation and destination creation | `ContentPresenterRouter`, `CoreRouter` |

In this project, VIPER grows out of the earlier MVVM steps, but it is not simply “MVVM with one more object.” In MVVM, the view model commonly owns state and presentation logic for the view. In the VIPER example, that role is called a **Presenter** because it coordinates two explicitly separated collaborators: the **Interactor** for feature work and the **Router** for navigation.

The Presenter still communicates with the View indirectly through observable presentation state and view events. It is not that the Presenter stops working with the View; rather, the View no longer owns routing decisions or business/data work. `ContentPresenter` loads products through `ContentPresenterInteractor`, and handles a product tap by calling `ContentPresenterRouter`.

The Entity name does not imply a different kind of object from a model. In this example, `Product` is the Entity and the model/domain data object at the same time.

## Architecture evolution

The architecture evolves by moving responsibilities out of the View and introducing a boundary only when the previous approach becomes difficult to test, reuse, or maintain:

| Step | Architecture | What changes | Why the next step is useful |
| --- | --- | --- | --- |
| 1 | No architecture | The View owns data and business logic. | The View becomes difficult to test and reuse. |
| 2 | MV | A shared data manager owns most application/data logic. | Business logic and data logic are still tightly coupled. |
| 3 | MVC | A controller is introduced between the View and data layer. | The controller can become a large “massive controller.” |
| 4 | MVVM | A ViewModel owns screen state and presentation/business logic. | The View becomes cleaner and business logic becomes testable. |
| 5 | MVVM + dependency injection | Dependencies are registered and constructed outside the ViewModel. | Dependencies become easier to replace, but concrete types can still leak into the design. |
| 6 | MVVM + protocols | The ViewModel depends on feature protocols instead of concrete services. | Tests can inject fakes and features become more decoupled. |
| 7 | Shared core interactor | Common manager access and orchestration are implemented once. | Shared behavior is easier to maintain, but a core interactor can grow too large. |
| 8 | Core builder/composition | Dependencies and destinations are assembled outside the views. | Routing is moved away from the View, but the overall design is still centered around MVVM. |
| 9 | VIPER-style composition | The View, Presenter, Interactor, Entity, and Router have explicit responsibilities. | Routing and feature work are fully separated from the View, at the cost of more setup and types. |

The current source demonstrates step 9 (`ContentView`). `DependenciesContainer` covers the composition concerns from steps 5 and 8, while `CoreRouter` demonstrates the VIPER routing boundary.

In short, the journey is:

```text
View owns everything
        ↓
Shared data manager
        ↓
MVC controller
        ↓
MVVM ViewModel
        ↓
Dependency injection
        ↓
Protocol-based boundaries
        ↓
Shared core interactor
        ↓
External composition and routing
        ↓
VIPER: View + Interactor + Presenter + Entity + Router
```

MVVM is the important turning point: it separates the View from most presentation and business logic. VIPER continues that separation by giving the Presenter explicit Interactor and Router collaborators, so the feature’s work and navigation do not remain inside the ViewModel/View relationship.

## Project structure

```text
Architecture/
├── ArchitectureApp.swift       # SwiftUI app entry point
├── Core/
│   ├── ContentView.swift       # VIPER-style presenter, interactor, router, DI container
│   └── ProfileView.swift       # CustomRouting examples
├── Helpers/
│   └── Helpers.swift           # Product models and DataService implementation
└── Assets.xcassets/
docs/
├── 00-architecture-complexity-spectrum.jpg        # Views only through MVVM overview
├── 01-no-architecture-simple-view-service.jpg     # One View directly calls one Service
├── 02-no-architecture-direct-service-dependencies.jpg # Many Views directly call Services
├── 03-mv-shared-environment-managers.jpg          # MV and shared SwiftUI Environment
├── 04-mvc-manager-boundary.jpg                    # MVC-style manager boundary
├── 05-mvvm-viewmodel.jpg                          # MVVM
├── 06-mvvm-feature-interactor-protocols.jpg       # MVVM plus feature interactors
├── 07-mvvm-shared-core-interactor.jpg             # Shared CoreInteractor
├── 08-mvvm-core-builder-composition.jpg           # Dependency composition with CoreBuilder
└── 09-viper-presenter-router.jpg                  # VIPER
```

## Notes

- The app entry point currently has `ContentView()` commented out, so the sample screen is composed in previews rather than launched by the app window.
- `MockDataService` is named as a mock, but currently performs a real request to `https://dummyjson.com/products`; a true test double should return deterministic in-memory data.
- Errors are currently printed from the presenter. A production implementation would expose loading and error state to the view.
- The project uses Swift 6 mode and the Observation framework’s `@Observable` macro.

## Requirements

- Xcode 26 or later
- iOS 26.5 deployment target (as configured in the project)
- Swift 6

Open `Architecture.xcodeproj` in Xcode to build and run the project.
