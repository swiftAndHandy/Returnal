//
//  Item.swift
//  Returnal
//
//  Created by Andre Veltens on 01.12.25.
//

import Foundation
import SwiftData

@Model
class Item: Identifiable {
    var id: UUID
    var name: String
    var details: String?
    var debtor: Borrower?
    
    static let types = ["Alle", "Verliehen", "Vorrätig"]
    
    init(name: String, details: String? = nil, debtor: Borrower? = nil) {
        self.id = UUID()
        self.name = name
        self.details = details
        self.debtor = debtor
    }
}
