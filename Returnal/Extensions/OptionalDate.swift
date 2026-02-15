//
//  OptionalDate.swift
//  Returnal
//
//  Created by Andre Veltens on 06.12.25.
//

import Foundation

extension Optional where Wrapped == Date {
    var isExceeded: Bool {
        isExceeded()
    }
    
    func isExceeded(comparedTo: Date = Date()) -> Bool {
        guard let value = self else { return false }
        let calendar = Calendar.current
        
        let comparisonDay = calendar.startOfDay(for: comparedTo)
        let valueEndOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: value))!
        
        
        return comparisonDay >= valueEndOfDay
    }
}
