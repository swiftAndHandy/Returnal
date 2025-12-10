//
//  ItemDetailsView.swift
//  Returnal
//
//  Created by Andre Veltens on 01.12.25.
//

import StoreKit
import SwiftData
import SwiftUI


struct ItemDetailsView: View {
    @AppStorage("scanCount") var scanCount: Int = 0
    @AppStorage("returnedItemsCount") var returnedItemsCount = 0
    
    @Bindable private var item: Item
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.requestReview) var requestReview
    @Environment(\.modelContext) var modelContext
    
    @FocusState private var descriptionIsFocused: Bool
    
    @State private var burrowSheetIsPresented: Bool = false
    @State private var borrowerHistoryIsPresented: Bool = false
    @State private var editModeisActice: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    
    @State var newDescription: String
    
    
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
                            
                            if #available(iOS 26.0, *) {
                                Button(role: .confirm) {
                                    if newDescription.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                                        item.details = newDescription
                                        try? modelContext.save()
                                    }
                                    editModeisActice = false
                                    descriptionIsFocused = false
                                } label: {
                                    Label("Speichern", systemImage: "checkmark.circle")
                                        .labelStyle(.iconOnly)
                                        .font(.system(size: 20))
                                        .foregroundStyle(.green)
                                }
                                .buttonStyle(.plain)
                            } else {
                                Button {
                                    if newDescription.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                                        item.details = newDescription
                                        try? modelContext.save()
                                    }
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
                    }
                    .padding(.vertical, 2)
                } else {
                    HStack {
                        Text(item.details ?? String(localized: .descriptionUnavailable))
                        if !item.isBorrowed {
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
                
                if item.isBorrowed, let debtor = item.debtors.last {
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
                            Spacer()
                            VStack {
                                Button("QR-Code drucken") {
                                    QRCode.printCode(item: item, size: 50)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            Spacer()
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
                switch item.isBorrowed {
                    case true:
                    Button {
                        item.isBorrowed = false
                        item.debtors.last?.dateOfReturning = Date.now
                        try? modelContext.save()
                        
                        returnedItemsCount += 1
                        
                        if returnedItemsCount >= 6 && returnedItemsCount % 3 == 0 {
                            requestReview()
                        }
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
            ToolbarItem {
                if historyIsEnabled() {
                    Button {
                        borrowerHistoryIsPresented = true
                    } label: {
                        Label("Vergangene Entleiher anzeigen", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                    }
                }
            }
        }
        .sheet(isPresented: $burrowSheetIsPresented) {
            AssignBorrowerView(item: item)
        }
        .sheet(isPresented: $borrowerHistoryIsPresented) {
            BorrowerHistoryView(for: item)
        }
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            Label("Gegenstand löschen", systemImage: "trash")
                .padding(4)
        }
        .buttonStyle(.borderedProminent)
        .disabled(item.isBorrowed)
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
    
    func historyIsEnabled() -> Bool {
        return (!item.debtors.isEmpty && !item.isBorrowed) || item.debtors.count >= 2
    }
}

#Preview {
    ItemDetailsView(for: Item(name: "Zollstock"))
}
