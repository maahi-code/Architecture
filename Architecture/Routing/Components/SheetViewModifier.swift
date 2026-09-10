//
//  SheetViewModifier.swift
//  Architecture
//
//  Created by Mahipal Singh on 10/09/26.
//

import SwiftUI

extension View {
    func sheetViewModifier(screen:  Binding<AnyDestination?>) -> some View {
        self
            .sheet(isPresented: Binding(ifNotNil: screen)) {
                ZStack {
                    if let screen = screen.wrappedValue {
                        screen.destination
                    }
                }
            }
        
    }
    func fullScreenCoverViewModifier(screen:  Binding<AnyDestination?>) -> some View {
        self
            .fullScreenCover(isPresented: Binding(ifNotNil: screen)) {
                ZStack {
                    if let screen = screen.wrappedValue {
                        screen.destination
                    }
                }
            }
        
    }
    
}
