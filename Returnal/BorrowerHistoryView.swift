//
//  BorrowerHistoryView.swift
//  Returnal
//
//  Created by Andre Veltens on 05.12.25.
//

import SwiftUI

struct BorrowerHistoryView: View {
    var item: Item
    var body: some View {
        ScrollView {
            ForEach(item.debtors, id: \.self) { borrower in
                Text(borrower.firstName)
            }
        }
    }
    
    init (for item: Item) {
        self.item = item
    }
}

#Preview {
    BorrowerHistoryView(for: Item(name: "Trittleiter", debtors: []))
}
