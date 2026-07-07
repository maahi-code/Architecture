//
//  ContentView.swift
//  Architecture
//
//  Created by Mahipal Singh on 06/07/26.
//

/*
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
 
 2. MV Architecture( Vanilla SwiftUI)
 - Data Manager shared accross the app
 - Data Manager are reponsible for business logic but and Data Logic
 
 Pros:
 - Less code
 - Easy to reuse bussiness logic
 
 Cons:
 - Tightly coupled business logic to the data logic
 - "Too Easy" to reuse data(other view's can effect each other)
 - Data Manager semi testable
 
 

 
 
 
 3. MVC Architecture (Vanilla SwiftUI)
 
 - There is a Data Manager,
 - Views are reponsible for some business logic but not Data Logic
 - Vies holds the Arrary of Products
 
 Pros:
  - Data Manager is shared across application
  - Data Manager is testable, mockable, or resuable
  
 Cons:
  - Business logic is not testable
  - Masive View Controller problem
 
 */
import SwiftUI
@MainActor
@Observable
class DataManager {
    private let service: DataService
    
    init(service: DataService) {
        self.service = service
    }
    
    func getProduct() async throws -> [Product] {
        try await service.getProduct()
    }
    
}
struct ContentView: View {
    @Environment(DataManager.self) private var dataManager
    @State private var products: [Product] = []
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(products) { product in
                Text(product.title)
            }
        }
        .padding()
        .task {
            await loadData()
        }
    }
    private func loadData() async {
        do {
            products = try await dataManager.getProduct()
        } catch {
            print(error)
        }
    }
}

#Preview {
    ContentView()
        .environment(DataManager(service: MockDataService()))
}
