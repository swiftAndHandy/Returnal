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
    
    var phoneNumber: String?
    var email: String?
    
    var address: Address?
    var dateOfBorrowing: Date
    var dateOfReturning: Date?
    var promissedDateOfReturning: Date?
    
    var borrowedItemDetails: String?
    
    init(firstName: String, lastName: String, phoneNumber: String? = nil, email: String? = nil, address: Address? = nil, borrowedItemDetails: String? = nil, promissedDateOfReturning: Date? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
        self.dateOfBorrowing = .now
        self.phoneNumber = phoneNumber
        self.email = email
        self.borrowedItemDetails = borrowedItemDetails
        self.promissedDateOfReturning = promissedDateOfReturning
    }
}
