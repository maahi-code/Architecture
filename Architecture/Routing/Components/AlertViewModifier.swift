//
//  AlertViewModifier.swift
//  Architecture
//
//  Created by Mahipal Singh on 10/09/26.
//

import SwiftUI

extension View {
    @ViewBuilder
    func showCustomAlert(type: AlertType = .alert, alert: Binding<AnyAppAlert?>) -> some View {
        switch type {
        case .alert:
            self
                .alert(
                    alert.wrappedValue?.title ?? "",
                    isPresented: Binding(ifNotNil: alert)
                ) {
                    alert.wrappedValue?.button()
                } message: {
                    if let subtitle = alert.wrappedValue?.subtitle {
                        Text(subtitle)
                    }
                }
        case .confirmationDialog:
            self
                .confirmationDialog(
                    alert.wrappedValue?.title ?? "",
                    isPresented: Binding(ifNotNil: alert)
                ) {
                    alert.wrappedValue?.button()
                } message: {
                    if let subtitle = alert.wrappedValue?.subtitle {
                        Text(subtitle)
                    }
                }
        }
    }
}
