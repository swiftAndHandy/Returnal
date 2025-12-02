//
//  Borrower.swift
//  Returnal
//
//  Created by Andre Veltens on 01.12.25.
//

import Foundation
import SwiftData

@Model
class Borrower {
    var firstName: String
    var lastName: String
    
    var phoneNumber: String
    var email: String
    
    var address: Address
    var dateOfBorrowing: Date
    
    init(firstName: String, lastName: String, phoneNumber: String = "", email: String = "", address: Address = Address()) {
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
        self.dateOfBorrowing = .now
        self.phoneNumber = phoneNumber
        self.email = email
    }
}
