
ARCHITECTURE NOTES

1. No Architecture (Vanilla SwiftUI)

- There is no Data Manager, Views are responsible for all business logic & Data Logic
- View Holds the Arrary of Products

Pros:
- Simplest Code
- Easy to setup, lower chances of bugs

Cons:
- No seperate between views and data layers
- Not testable, mockable, or resuable

// 2. 



3. MVC Architecture (Vanilla SwiftUI)

- There is a Data Manager, Views are reponsible for some business logic but not Data Logic
- Vies holds the Arrary of Products

Pros:
- Data Manager is shared across application
- Data Manager is testable, mockable, or resuable

Cons:
- Business logic is not testable
- Masive View Controller problem
