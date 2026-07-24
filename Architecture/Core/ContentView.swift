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


@MainActor
protocol ContentViewModelInteractor {
    func getProduct() async throws -> [Product]
    func getUser() async throws -> String
}

protocol HomeViewModelInteractor {
    func getMovies() async throws -> [String]
    func getUser() async throws -> String
}

struct CoreInteractor: HomeViewModelInteractor, ContentViewModelInteractor {
    let dataManager: DataManager
    let userManager: UserManager
    
    init(container: DependenciesContainer) {
        self.dataManager = container.resolve(DataManager.self)!
        self.userManager = container.resolve(UserManager.self)!
    }
    
    func getProduct() async throws -> [Product] {
        try await dataManager.getProduct()
    }

    func getUser() async throws -> String {
        try await userManager.getUser()
    }
    
    func getMovies() async throws -> [String] {
        try await dataManager.getMovies()
    }
    
    
    
}

import SwiftUI
@MainActor
@Observable
class UserManager {
    
    func getUser() async throws -> String {
        "User_1"
    }
    
}
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
    
    func getMovies() async throws -> [String] {
        ["Obsession"]
    }
    
}
//struct ProductionContentViewModelInteractor: ContentViewModelInteractor {
//   
//    let dataManager: DataManager
//    let userManager: UserManager
//    
//    init(container: DependenciesContainer) {
//        self.dataManager = container.resolve(DataManager.self)!
//        self.userManager = container.resolve(UserManager.self)!
//    }
//    
//    
//    func getProduct() async throws -> [Product] {
//        try await dataManager.getProduct()
//    }
//
//    func getUser() async throws -> String {
//        try await userManager.getUser()
//    }
//    
//}

//struct MockContentViewModelInteractor: ContentViewModelInteractor {
//   
//    
//    func getProduct() async throws -> [Product] {
//        [
//            Product(id: 1, title: "My first project")
//        ]
//    }
//
//    func getUser() async throws -> String {
//        "_new_user"
//    }
//    
//}

@Observable
class ContentViewModel {
   let interactor: ContentViewModelInteractor
    
    var products: [Product] = []
    
    init(interactor: ContentViewModelInteractor) {
        self.interactor = interactor
    }
    func loadData() async {
        do {
            let _ = try await interactor.getUser()
            products = try await interactor.getProduct()
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

struct HomeView: View {
    @State var viewModel: HomeViewModel
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(viewModel.movies, id: \.self) { movie in
                Text(movie)
                    .foregroundStyle(.blue)
            }
        }
        .padding()
        .task {
            await viewModel.loadData()
        }
    }
}
//struct ProductionHomeViewModelInteractor: HomeViewModelInteractor {
//    let dataManager: DataManager
//    let userManager: UserManager
//    
//    init(container: DependenciesContainer) {
//        self.dataManager = container.resolve(DataManager.self)!
//        self.userManager = container.resolve(UserManager.self)!
//    }
//
//    func getUser() async throws -> String {
//        try await userManager.getUser()
//    }
//    
//    func getMovies() async throws -> [String] {
//        try await dataManager.getMovies()
//    }
//    
//}


@MainActor
@Observable
class HomeViewModel {
    let interactor: HomeViewModelInteractor
     
    var movies: [String] = []
     
    init(interactor: HomeViewModelInteractor) {
         self.interactor = interactor
     }
     func loadData() async {
         do {
             let _ = try await interactor.getUser()
             movies = try await interactor.getMovies()
         } catch {
             print(error)
         }
     }
}

@MainActor
class DependenciesContainer {
    private var services: [String: Any] = [:]
    
    func register<T>(_ type: T.Type, service: T) {
        let key = "\(type)"
        services[key] = service
    }
    func register<T>(_ type: T.Type, service: () -> T) {
        let key = "\(type)"
        services[key] = service()
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        let key = "\(type)"
        return services[key] as? T
    }
}
#Preview {
    let container = DependenciesContainer()
    container.register(DataManager.self, service: DataManager(service: MockDataService()))
    container.register(UserManager.self, service: UserManager())
//    return HomeView(viewModel: HomeViewModel(interactor: CoreInteractor(container: container)))
    return  ContentView(viewModel: ContentViewModel(interactor: CoreInteractor(container: container)))
}
