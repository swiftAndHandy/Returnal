//
//  Owner.swift
//  Returnal
//
//  Created by Andre Veltens on 09.12.25.
//

import Foundation
import SwiftData

@Model
class Owner: Identifiable {
    var id: UUID
    
    var firstName: String
    var lastName: String
    
    var phoneNumber: String?
    var email: String?
    
    var address: Address?
    
    
    init(firstName: String, lastName: String, phoneNumber: String? = nil, email: String? = nil, address: Address? = nil) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.email = email
        self.address = address
    }
    
    
}
