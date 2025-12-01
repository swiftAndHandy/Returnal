//
//  Address.swift
//  Returnal
//
//  Created by Andre Veltens on 01.12.25.
//

import Foundation
import SwiftData

@Model
class Address {
    var street: String
    var postalCode: String
    var city: String
    var country: String
    
    init(street: String, postalCode: String, city: String, country: String) {
        self.street = street
        self.postalCode = postalCode
        self.city = city
        self.country = country
    }
}
