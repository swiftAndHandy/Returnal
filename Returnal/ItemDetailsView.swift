//
//  ItemDetailsView.swift
//  Returnal
//
//  Created by Andre Veltens on 01.12.25.
//

import SwiftData
import SwiftUI


struct ItemDetailsView: View {
    @State var item: Item
    @State var editItemIsPresented: Bool = false
    @State var burrowSheetIsPresented: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(item.name)
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                
                Text(item.details ?? "Keine Beschreibung verfügbar.")
                    .font(.caption)
                
                Divider()
                
                if let debtor = item.debtor {
                    VStack(alignment: .leading) {
                        Text("Verliehen an:")
                            .font(.caption)
                        Text("\(debtor.firstName) \(debtor.lastName)")
                    }
                    Divider()
                }
            
                
                VStack {
                    Text("Konfiguration:")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        QRCode(for: item.id, size: 150)
                        VStack {
                            Text("ID: \n\(item.id)")
                        }
                    }
                }
                
            }
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
        .toolbar {
            switch isBorrowed() {
                case true:
                Button {
                    item.debtor = nil
                } label: {
                    HStack(spacing: 4) {
                        Text("Erhalt bestätigen")
                        Image(systemName: "hand.thumbsup")
                    }
                    .accessibilityLabel("Rückgabe")
                    .accessibilityHint("Tippe hier, wenn der Gegenstand zurückgegeben wurde.")
                }
            case false:
                Button {
                    burrowSheetIsPresented.toggle()
                    item.debtor = Borrower(firstName: "Kevin", lastName: "Chromik")
                } label: {
                    HStack(spacing: 4) {
                        Text("Verleihen")
                        Image(systemName: "hand.palm.facing")
                    }
                    .accessibilityLabel("Verleihen")
                    .accessibilityHint("Tippe hier, um einen Entleiher festzulegen.")
                }
            }
        }
        .sheet(isPresented: $burrowSheetIsPresented) {
            
        }
    }
    
    init(for item: Item) {
        self.item = item
    }
    
    func isBorrowed() -> Bool {
        item.debtor != nil
    }
}

#Preview {
    ItemDetailsView(for: Item(name: "Zollstock"))
}
