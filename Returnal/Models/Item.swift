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
    @Relationship(deleteRule: .cascade) var images: [ImageAsset]
    
    var owner: UUID?
    
    
    var qrCodeNeverScanned: Bool = true
    
    init(name: String, details: String? = nil, owner: UUID? = nil, debtors: [Borrower] = [], images: [ImageAsset] = []) {
        self.id = UUID()
        self.name = name
        self.details = details
        self.owner = owner != nil ? owner : nil
        self.debtors = debtors
        self.images = images
        self.isBorrowed = debtors.isEmpty ? false : true
    }
}
