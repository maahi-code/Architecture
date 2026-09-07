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
    var destination: AnyView
    init<T: View> (destination: T) {
        self.destination = AnyView(destination)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AnyDestination, rhs: AnyDestination) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension EnvironmentValues {
    @Entry var router: Router = MockRouter()
}


struct MockRouter: Router {
    func showScreen<T>(destination: @escaping (any Router) -> T) where T : View {
        print("Mock Router don't work!!!")
    }
    func dismissScreen() {
        print("Mock Router don't work!!!")
    }
}

protocol Router {
    func showScreen<T: View>(@ViewBuilder destination: @escaping (Router) -> T)
    func dismissScreen()
}



struct RouterView<Content: View> : View, Router {
    @State private var path: [AnyDestination] = []
    
    // @Binding to the view stack from previous RouteViews
    @Binding var screenStack: [AnyDestination]
    
    var addNavigationView: Bool
    
    @ViewBuilder var content: (Router) -> Content
    
    @Environment(\.dismiss) private var dismiss
    
    init(
        screenStack: (Binding<[AnyDestination]>)? = nil,
        addNavigationView: Bool = true,
        content: @escaping (Router) -> Content,
    ) {
        self._screenStack = screenStack ?? .constant([])
        self.addNavigationView = addNavigationView
        self.content = content
    }
    
    
    var body: some View {
        NavigationStackIfNeeded(path: $path, addNavigationView: addNavigationView) {
            content(self)
        }
        .environment(\.router, self)
    }
    
    
    
    func showScreen<T: View>(@ViewBuilder destination: @escaping (Router) -> T) {
        let screen = RouterView<T>(
            screenStack: screenStack.isEmpty ? $path : $screenStack,
            addNavigationView: false) { newRouter in
                destination(newRouter)
            }
        let destination = AnyDestination(destination: screen)
        if screenStack.isEmpty {
            // This means we are on the main RouterView
            path.append(destination)
        } else {
            // This means we are on the secondary RouterView
            screenStack.append(destination)
        }
        
    }
    
    func dismissScreen() {
        dismiss()
    }
}

/*
  RouterView - @Environment
     ProfileView
       RouterView - @Environment
          SettingsView
            RouterView - @Environment
               AccountView
 
 
 
 
 */

struct NavigationStackIfNeeded<Content: View> : View {
    @Binding var path: [AnyDestination]
    var addNavigationView: Bool = true
    @ViewBuilder var content: Content
    var body: some View {
        if addNavigationView {
            NavigationStack(path: $path) {
                content
                    .navigationDestination(for: AnyDestination.self) { value in
                        value.destination
                    }
            }
        } else {
            content
        }
    }
}
struct ProfileView: View {
    @State private var path: [AnyDestination] = []
    @Environment(\.router) private var router
    var body: some View {
        VStack(spacing: 50) {
            Button {
                router.showScreen { _ in
                    SettingsView()
                }
            } label: {
                Text("Go to the Settings")
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.router) var router
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            VStack{
                Text("Settings")
                    .font(.title)
                    .foregroundStyle(.white)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Spacer()
                HStack {
                    
                    Button {
                        router.dismissScreen()
                    } label: {
                        Text("Previous")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                            
                    }
                    .buttonStyle(.glass)
                    .padding(.horizontal)
                    
                    
                    Button {
                        router.showScreen { _ in
                            AccountView()
                        }
                    } label: {
                        Text("Account Screen")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                            
                    }
                    .buttonStyle(.glass)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            
        }
    }
}
struct AccountView: View {
    @Environment(\.router) var router
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            VStack{
                Text("Account")
                    .font(.title)
                    .foregroundStyle(.white)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Spacer()
                HStack {
                    
                    Button {
                        router.dismissScreen()
                    } label: {
                        Text("Previous")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                            
                    }
                    .buttonStyle(.glass)
                    .padding(.horizontal)
                    
                    
                    Button {
                        router.showScreen { _ in
                            AccountView()
                        }
                    } label: {
                        Text("Account Screen")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                            
                    }
                    .buttonStyle(.glass)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            
        }
    }
}

#Preview {
    RouterView { _ in
        ProfileView()
    }
}


extension View {
    func any() -> AnyView {
        AnyView(self)
    }
}
