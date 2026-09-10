//
//  View+Ext.swift
//  Architecture
//
//  Created by Mahipal Singh on 10/09/26.
//
import SwiftUI

extension View {
    func any() -> AnyView {
        AnyView(self)
    }
}
