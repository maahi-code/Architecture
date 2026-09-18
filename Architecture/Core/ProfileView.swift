//
//  ProfileView.swift
//  Architecture
//
//  Created by Mahipal Singh on 02/09/26.
//

import SwiftUI
import CustomRouting

struct ProfileView: View {
    @State private var path: [AnyDestination] = []
    @Environment(\.router) private var router
    var body: some View {
        List {
            segueSection
            alertSection
            modalSection
            
        }
        .navigationTitle("Routing Examples")
        
        
    }
    private var segueSection: some View {
        Section {
            Button {
                router.showScreen(.push) { _ in
                    ProfileView()
                }
            } label: {
                Text("Push")
            }
            Button {
                router.showScreen(.sheet) { _ in
                    ProfileView()
                }
            } label: {
                Text("Sheet")
            }
            Button {
                router.showScreen(.fullScreenCover) { _ in
                    ProfileView()
                }
            } label: {
                Text("FullScreenCover")
            }
            Button {
                router.dismissScreen()
            } label: {
                Text("Dismiss")
            }
        } header: {
            Text("Segues")
        }
    }
    
    private var alertSection: some View {
        Section {
            Button {
                router.showAlert(.alert, title: "Alert One", subtitle: "This is the first alert", button: nil)
            } label: {
                Text("Alert")
            }
            Button {
                router.showAlert(
                        .confirmationDialog,
                        title: "Confirmation Dialog One",
                        subtitle: "This is the Confirmation Dialog") {
                            AnyView(
                                Group {
                                    Button("Alpha") {}
                                    Button("Beta") {}
                                    Button("Gamma") {}
                                    Button(role: .close) {}
                                }
                            )
                        }
            } label: {
                Text("Confirmation Dialog")
            }
            
            Button("Dismiss Alert") {
                router.dimissAlert()
            }
        } header: {
            Text("Alerts")
        }
    }
    
    private var modalSection: some View  {
        Section {
            Button {
                router
                    .showModal(
                        backgroundColor: .red.opacity(0.2),
                        transition: .slide
                    ) {
                            RoundedRectangle(cornerRadius: 30)
                                .fill(.blue)
                                .frame(maxHeight: 250)
                                .padding(40)
                                .onTapGesture {
                                    router.dismissModal()
                                }
                        }
            } label: {
                Text("Modal")
            }
            Button {
                router.dismissModal()
            } label: {
                Text("Dismiss Modal")
            }
        } header: {
            Text("Modals")
        }
    }
}

#Preview {
    RouterView { _ in
        ProfileView()
    }
}



