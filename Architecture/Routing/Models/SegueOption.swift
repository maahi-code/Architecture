//
//  SegueOption.swift
//  Architecture
//
//  Created by Mahipal Singh on 10/09/26.
//

import SwiftUI

enum SegueOption {
    case push, sheet, fullScreenCover
    
    var shouldAddNewNavigationView: Bool {
        switch self {
        case .push:
            return false
        case .sheet, .fullScreenCover:
            return true
        }
    }
}
