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
    @State var editModeisActice: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(item.name)
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if editModeisActice {
                    
                } else {
                    HStack {
                        Text(item.details ?? "Keine Beschreibung verfügbar.")
                            .font(.caption)
                        Button { } label: {
                            Label("", systemImage: "pencil.circle")
                                .foregroundStyle(.primary)
                                .font(.headline)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                
                Divider()
                
                if let debtor = item.debtor {
                    HStack(alignment: .top , spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Verliehen an:")
                                .font(.caption)
                            Text("\(debtor.firstName) \(debtor.lastName)")
                            if let address = debtor.address {
                                Divider()
                                HStack {
                                    Text("\(address.zipCode ?? "")")
                                    Text("\(address.city ?? "")")
                                }
                            }
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Verliehen am:")
                                .font(.caption)
                            Text("\(debtor.dateOfBorrowing.formatted(date: .long, time: .omitted))")
                        }
                    }
                    Divider()
                }
            
                
                VStack {
                    Text("Konfiguration:")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        let uiImage = QRCode.drawCode(uuid: item.id)
                        if let qrCode = uiImage {
                            QRCodeView(for: qrCode, size: 150)
                            VStack {
                                Text("ID: \n\(item.id)")
                            }
                        } else {
                            
                        }
                    }
                }
                
            }
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
        .toolbar {
            ToolbarItem {
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
        }
        .sheet(isPresented: $burrowSheetIsPresented) {
            AssignBorrowerView(item: item)
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
