//
//  NoFilteredItemsView.swift
//  Returnal
//
//  Created by Andre Veltens on 02.12.25.
//

import SwiftUI

struct NoFilteredItemsView: View {
    var body: some View {
        ContentUnavailableView(
            label: {
                Label("Keine Suchergebnisse", systemImage: "magnifyingglass")
            },
            description: {
                Text("Der aktuelle Filter liefert keine Ergebnisse.")
            }
        )
    }
}

#Preview {
    NoFilteredItemsView()
}
