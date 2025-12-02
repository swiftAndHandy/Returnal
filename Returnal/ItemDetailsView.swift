//
//  ItemDetailsView.swift
//  Returnal
//
//  Created by Andre Veltens on 01.12.25.
//

import SwiftData
import SwiftUI


struct ItemDetailsView: View {
    @Bindable private var item: Item
    @State private var burrowSheetIsPresented: Bool = false
    @State private var editModeisActice: Bool = false
    @FocusState private var descriptionIsFocused: Bool
    
    @State var newDescription: String
    
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(item.name)
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if editModeisActice {
                    HStack {
                        TextEditor(text: $newDescription)
                            .focused($descriptionIsFocused)
                            .font(.caption)
                            .frame(minHeight: 30)
                            .scrollBounceBehavior(.basedOnSize)
                        HStack {
                            Button {
                                newDescription = item.details ?? ""
                                editModeisActice = false
                                descriptionIsFocused = false
                            } label: {
                                Label("Verwerfen", systemImage: "multiply")
                                    .labelStyle(.iconOnly)
                            }
                            
                            Button {
                                item.details = newDescription
                                try? modelContext.save()
                                editModeisActice = false
                                descriptionIsFocused = false
                            } label: {
                                Label("Speichern", systemImage: "checkmark")
                                    .labelStyle(.iconOnly)
                            }
                            
                        }
                    }
                    .padding(.vertical, 2)
                } else {
                    HStack {
                        Text(item.details ?? "Keine Beschreibung verfügbar.")
                            .font(.caption)
                        if item.debtor == nil {
                            Button {
                                editModeisActice = true
                                descriptionIsFocused = true
                            } label: {
                                Label("", systemImage: "pencil.circle")
                                    .foregroundStyle(.primary)
                                    .font(.headline)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                
                Divider()
                
                if let debtor = item.debtor {
                    VStack(alignment: .leading) {
                        HStack(alignment: .top , spacing: 16) {
                            VStack(alignment: .leading) {
                                Text("Verliehen an:")
                                    .font(.caption)
                                Text("\(debtor.firstName) \(debtor.lastName)")
                                    .font(.default.bold())
                                if let address = debtor.address {
                                    Text("\(address.street ?? "")")
                                        .font(.subheadline)
                                    HStack {
                                        Text("\(address.zipCode ?? "")")
                                            .font(.subheadline)
                                        Text("\(address.city ?? "")")
                                            .font(.subheadline)
                                    }
                                    Text("\(address.country ?? "")")
                                        .font(.subheadline)
                                }
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Verliehen am:")
                                    .font(.caption)
                                Text("\(debtor.dateOfBorrowing.formatted(date: .long, time: .omitted))")
                            }
                        }
                        if debtor.email != nil || debtor.phoneNumber != nil {
                            Divider()
                                .padding(.bottom)
                            if let email = debtor.email {
                                HStack {
                                    Text("E-Mail:")
                                    Text("\(email)")
                                }
                                .font(.subheadline)
                            }
                            if let phoneNumber = debtor.phoneNumber {
                                HStack {
                                    Text("Telefon:")
                                    Text("\(phoneNumber)")
                                }
                                .font(.subheadline)
                            }
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
                        try? modelContext.save()
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
        self.newDescription = item.details ?? ""
    }
    
    func isBorrowed() -> Bool {
        item.debtor != nil
    }
}

#Preview {
    ItemDetailsView(for: Item(name: "Zollstock"))
}
