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
    
    @Relationship(deleteRule: .cascade) var debtors: [Borrower]
    
    var qrCodeNeverScanned: Bool = true
    
    init(name: String, details: String? = nil, debtors: [Borrower] = []) {
        self.id = UUID()
        self.name = name
        self.details = details
        self.debtors = debtors
        
        self.isBorrowed = debtors.isEmpty ? false : true
    }
}
