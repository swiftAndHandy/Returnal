//
//  FilteredItemsView.swift
//  Returnal
//
//  Created by Andre Veltens on 03.12.25.
//

import SwiftUI

struct FilteredItemsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    private var items: [Item]
    
    var body: some View {
        List {
            ForEach(items) { item in
                NavigationLink(value: item) {
                    HStack {
                        Text("\(item.name)")
                        Spacer()
                        VStack(alignment: .leading) {
                            if let _ = item.debtor {
                                Text("verliehen")
                                    .foregroundStyle(.red)
                            }
                            if item.qrCodeNeverScanned {
                                Text("ungescannt")
                                    .foregroundStyle(
                                        colorScheme == .light ? .purple : .cyan
                                    )
                            }
                        }
                    }
                }
            }
        }
    }
    
    init(items: [Item]) {
        self.items = items
    }
}

#Preview {
    FilteredItemsView(items: [Item(name:"Werkzeugkasten")])
}
