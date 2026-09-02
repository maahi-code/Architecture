//
//  ProfileView.swift
//  Architecture
//
//  Created by Mahipal Singh on 02/09/26.
//

import SwiftUI
enum NavigationDestinationOption: Hashable {
    case intergerScreen(int: Int)
    case stringScreen(str: String)
    case someOtherScreen(bool: Bool)
}


struct AnyDestination: Hashable {
    let id = UUID().uuidString
    var destination: () -> AnyView
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AnyDestination, rhs: AnyDestination) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
struct ProfileView: View {
    @State private var path: [AnyDestination] = []
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 50) {
                Button {
                    path.append(AnyDestination(destination: {
                        Text("Hello There!").any()
                    }))
                } label: {
                    Text("Click me")
                }
                
                Button {
                    path.append(AnyDestination(destination: {
                        Text("Integer!").any()
                    }))
                } label: {
                    Text("Click me")
                        .foregroundStyle(.red)
                }
                Button {
                    goToContentView()
                } label: {
                    Text("CLICK ME")
                        .foregroundStyle(.black)
                }
                
            }
            .navigationDestination(for: AnyDestination.self) { value in
                value.destination()
            }
        }
    }
    
    func goToContentView() {
        let container = DependenciesContainer()
        container.register(DataManager.self, service: DataManager(service: MockDataService()))
        container.register(UserManager.self, service: UserManager())
        path.append(
            AnyDestination(destination: {
                ContentView(viewModel: ContentViewModel(interactor: CoreInteractor(container: container)))
                    .any()
            }))
    }
}

#Preview {
    ProfileView()
}


extension View {
    func any() -> AnyView {
        AnyView(self)
    }
}
