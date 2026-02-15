//
//  NoItemsView.swift
//  Returnal
//
//  Created by Andre Veltens on 02.12.25.
//

import SwiftUI

struct NoItemsView: View {
    @Binding var addItemIsPresented: Bool
    
    var body: some View {
        ContentUnavailableView(
            label: {
                Label("Keine Einträge vorhanden", systemImage: "shippingBox")
            },
            description: {
                Button {
                    addItemIsPresented = true
                } label: {
                    Text("Füge deinen ersten Gegenstand hinzu.")
                }
            }
        )
    }
}

#Preview {
    NoItemsView(addItemIsPresented: .constant(false))
}
