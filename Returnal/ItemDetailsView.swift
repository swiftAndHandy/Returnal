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
    @State private var showDeleteConfirmation: Bool = false
    @FocusState private var descriptionIsFocused: Bool
    
    @State var newDescription: String
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
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
                            .frame(minHeight: 30)
                            .scrollBounceBehavior(.basedOnSize)
                        HStack(spacing: 20) {
                            Button(role: .cancel) {
                                newDescription = item.details ?? ""
                                editModeisActice = false
                                descriptionIsFocused = false
                            } label: {
                                Label("Verwerfen", systemImage: "multiply.circle")
                                    .labelStyle(.iconOnly)
                                    .font(.system(size: 20))
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)
                            
                            Button(role: .confirm) {
                                item.details = newDescription
                                try? modelContext.save()
                                editModeisActice = false
                                descriptionIsFocused = false
                            } label: {
                                Label("Speichern", systemImage: "checkmark.circle")
                                    .labelStyle(.iconOnly)
                                    .font(.system(size: 20))
                                    .foregroundStyle(.green)
                            }
                            .buttonStyle(.plain)
                            
                        }
                    }
                    .padding(.vertical, 2)
                } else {
                    HStack {
                        Text(item.details ?? "Keine Beschreibung verfügbar.")
                        if item.debtor == nil {
                            Button {
                                editModeisActice = true
                                descriptionIsFocused = true
                            } label: {
                                Label("Bearbeiten", systemImage: "pencil.line")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.primary)
                                    .font(.headline)
                                    .labelStyle(.iconOnly)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                
                Divider()
                
                if let debtor = item.debtor {
                    DebtorView(debtor: debtor, itemName: item.name)
                }
            
                
                VStack {
                    Text("Konfiguration:")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack() {
                        let uiImage = QRCode.drawCode(uuid: item.id)
                        if let qrCode = uiImage {
                            QRCodeView(for: qrCode, size: 150)
                            VStack {
                                Text("ID: \n\(item.id)")
                                Button("Drucken") {
                                    QRCode.printCode(item: item, size: 50)
                                }
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
        
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            Label("Gegenstand löschen", systemImage: "trash")
                .padding(4)
        }
        .buttonStyle(.borderedProminent)
        .disabled(item.debtor != nil)
        .alert("Gegenstand wirklich löschen?", isPresented: $showDeleteConfirmation) {
            Button("Abbrechen", role: .cancel) { }
            Button("Ja, löschen", role: .destructive) {
                modelContext.delete(item)
                try? modelContext.save()
                dismiss()
            }
        } message: {
            Text("Dieser Vorgang kann nicht rückgängig gemacht werden.")
        }
        .padding()
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
