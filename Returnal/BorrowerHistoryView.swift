//
//  BorrowerHistoryView.swift
//  Returnal
//
//  Created by Andre Veltens on 05.12.25.
//

import SwiftUI

struct BorrowerHistoryView: View {
    var borrowers: [Borrower]
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
    
    init (_ borrowers: [Borrower]) {
        self.borrowers = borrowers
    }
}

#Preview {
    BorrowerHistoryView([])
}
