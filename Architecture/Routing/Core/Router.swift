//
//  Router.swift
//  Architecture
//
//  Created by Mahipal Singh on 10/09/26.
//
import SwiftUI

extension EnvironmentValues {
    @Entry var router: Router = MockRouter()
}


struct MockRouter: Router {
    func showScreen<T: View>(_ segue: SegueOption, @ViewBuilder destination: @escaping (Router) -> T) where T : View {
        print("Mock Router don't work!!!")
    }
    func dismissScreen() {
        print("Mock Router don't work!!!")
    }
    func showAlert(_ option: AlertType,  title: String, subtitle: String? = nil, button: (@Sendable () -> AnyView)? = nil) {
        print("Mock Router don't work!!!")
    }
    func dimissAlert() {
        print("Mock Router don't work!!!")
    }
    func showModal<T: View>(backgroundColor: Color, transition: AnyTransition, @ViewBuilder destination: @escaping () -> T) {
        print("Mock Router don't work!!!")
    }
    
    func dismissModal() {
        print("Mock router don't work !!!")
    }
    
}

protocol Router {
    func showScreen<T: View>(_ segue: SegueOption, @ViewBuilder destination: @escaping (Router) -> T)
    func dismissScreen()
    func showAlert(_ option: AlertType,  title: String, subtitle: String?, button: (@Sendable () -> AnyView)?) 
    func dimissAlert()
    func showModal<T: View>(backgroundColor: Color, transition: AnyTransition, @ViewBuilder destination: @escaping () -> T)
    func dismissModal()
}
