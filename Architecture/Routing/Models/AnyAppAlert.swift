//
//  AnyAppAlert.swift
//  Architecture
//
//  Created by Mahipal Singh on 10/09/26.
//

import SwiftUI

struct AnyAppAlert: Sendable {
    var title: String
    var subtitle: String?
    var button: @Sendable () -> AnyView

    init(
        title: String,
        subtitle: String? = nil,
        button: (@Sendable () -> AnyView)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.button = button ?? {
            AnyView(
                Button("Ok") { }
            )
        }
    }

    init(error: Error) {
        self.init(
            title: "Error",
            subtitle: error.localizedDescription,
            button: nil
        )
    }
}

