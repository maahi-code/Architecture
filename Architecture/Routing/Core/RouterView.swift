//
//  RouterView.swift
//  Architecture
//
//  Created by Mahipal Singh on 10/09/26.
//

import SwiftUI

/*
  RouterView - @Environment
     ProfileView
       RouterView - @Environment
          SettingsView
            RouterView - @Environment
               AccountView
 
 
 
 
 */

struct RouterView<Content: View> : View, Router {
    @State private var path: [AnyDestination] = []
    
    
    @State private var showSheet: AnyDestination? = nil
    @State private var showFullScreenCover: AnyDestination? = nil
    
    @State var alert: AnyAppAlert? = nil
    @State var alertOption: AlertType = .alert
    
    @State private var modal: AnyDestination? = nil
    @State private var modalBackgroundColor: Color =  Color.black.opacity(0.6)
    @State private var modalTransition: AnyTransition = .opacity
    
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
                .sheetViewModifier(screen: $showSheet)
                .fullScreenCoverViewModifier(screen: $showFullScreenCover)
                .showCustomAlert(type: alertOption, alert: $alert)
                .modalViewModifier(
                    backgroundColor: modalBackgroundColor,
                    transition: modalTransition,
                    screen: $modal
                )
        }
       
        .environment(\.router, self)
    }
    
    
    
    func showScreen<T: View>(_ option: SegueOption, @ViewBuilder destination: @escaping (Router) -> T) {
        let screen = RouterView<T>(
            screenStack: option.shouldAddNewNavigationView ? nil : (screenStack.isEmpty ? $path : $screenStack),
            addNavigationView: option.shouldAddNewNavigationView) { newRouter in
                destination(newRouter)
            }
        let destination = AnyDestination(destination: screen)
        switch option {
        case .push:
            if screenStack.isEmpty {
                // This means we are on the main RouterView
                path.append(destination)
            } else {
                // This means we are on the secondary RouterView
                screenStack.append(destination)
            }
        case .sheet:
            showSheet = destination
        case .fullScreenCover:
            showFullScreenCover = destination
        }
    }
    
    func dismissScreen() {
        dismiss()
    }
    func showAlert(_ option: AlertType,  title: String, subtitle: String? = nil, button: (@Sendable () -> AnyView)? = nil) {
        self.alertOption = option
        self.alert = AnyAppAlert(title: title, subtitle: subtitle, button: button)
    }
    func dimissAlert() {
        alert = nil
    }
    
    func showModal<T: View>(backgroundColor: Color, transition: AnyTransition, @ViewBuilder destination: @escaping () -> T) {
        self.modalBackgroundColor = backgroundColor
        self.modalTransition = transition
        let destination = AnyDestination(destination: destination())
        self.modal = destination
    }
    
    func dismissModal() {
        modal = nil
    }
}
