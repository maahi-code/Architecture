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
 
 
 4. MVVM Architecture
 
 - Data Manager shared accross the app, but access from the View Model
 - ViewModels are reponsible for business logic
 - ViewModels holds the array of products
 
 
Pros:
 - Seperated the View from business logic
 - Business logic is now testable
 - View code much now much cleaner
 
 
Cons:
 - More difficult to setup and inject dependencies
 - ViewModel lifecycle is outside of View lifecycle ( Cannot use SwiftUI Property wrappersW
 
 
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
@Observable
class ContentViewModel {
    let dataManager: DataManager
    var products: [Product] = []
    var products2: [Product] = []
    var products3: [Product] = []
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    func loadData() async {
        do {
            products = try await dataManager.getProduct()
        } catch {
            print(error)
        }
    }
}
struct ContentView: View {
    @State var viewModel: ContentViewModel
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(viewModel.products) { product in
                Text(product.title)
            }
        }
        .padding()
        .task {
            await viewModel.loadData()
        }
    }
}

#Preview {
    ContentView(
        viewModel: ContentViewModel(dataManager: DataManager(service: MockDataService())))
}
