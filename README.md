
## Architecture 

### 1. No Architecture (Vanilla SwiftUI)

- No data manager is used.
- The view is responsible for both business logic and data logic.
- The view often holds the product array directly.

Pros:
- Simplest setup
- Easy to understand
- Fewer moving parts

Cons:
- Tight coupling between UI and data logic
- Harder to test and reuse

### 2. MV Architecture (Vanilla SwiftUI)

 - Data Manager shared accross the app
 - Data Manager are reponsible for business logic but and Data Logic
 
 Pros:
 - Less code
 - Easy to reuse bussiness logic
 
 Cons:
 - Tightly coupled business logic to the data logic
 - "Too Easy" to reuse data(other view's can effect each other)
 - Data Manager semi testable

### 3. MVC Architecture (Vanilla SwiftUI)

- The view handles presentation.
- A data manager or controller-like component handles app logic.
- Data-related responsibilities are separated from UI code.

Pros:
- Better organization than pure view-based code
- Shared data handling across the app
- More testable than no-architecture approaches

Cons:
- Business logic may still be hard to test in isolation
- Can grow into a large, hard-to-maintain view/controller structure

