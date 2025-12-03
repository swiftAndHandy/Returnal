//
//  FilterTypes.swift
//  Returnal
//
//  Created by Andre Veltens on 03.12.25.
//

import Foundation

struct Filter {
    enum types: String, CaseIterable {
        case all = "Alle"
        case borrowed = "Verliehen"
        case available = "Verfügbar"
        case unscanned = "Ungescannt"
    }
}
