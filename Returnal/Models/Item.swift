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
    var isBorrowed: Bool
    
    @Relationship(deleteRule: .cascade) var debtor: [Borrower]
    
    var qrCodeNeverScanned: Bool = true
    
    init(name: String, details: String? = nil, debtor: [Borrower] = []) {
        self.id = UUID()
        self.name = name
        self.details = details
        self.debtor = debtor
        
        self.isBorrowed = debtor.isEmpty ? false : true
    }
}
