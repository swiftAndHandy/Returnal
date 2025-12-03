//
//  AddItemView.swift
//  Returnal
//
//  Created by Andre Veltens on 01.12.25.
//

import SwiftData
import SwiftUI

struct AddItemView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var itemName: String = ""
    @State private var itemDescription: String = ""
    
    var onCreated: (Item) -> Void
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Pflichtangaben") {
                    TextField("Name des Gegenstands", text: $itemName)
                }
                Section("Ergänzende Angaben") {
                    TextEditor(text: $itemDescription)
                        .frame(minHeight: 250)
                }
            }
            .navigationTitle("Neuer Gegenstand")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Abbrechen", systemImage: "multiply")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveItem()
                    } label: {
                        Label("Speichern", systemImage: "checkmark")
                    }
                    .disabled(saveDisabled())
                }
            }
        }
    }
    
    func saveDisabled() -> Bool {
        return itemName.trimmingCharacters(in: .whitespaces).count < 3
    }
    
    func saveItem() {
        let trimmedName = itemName.trimmingCharacters(in: .whitespaces)
        let trimmedDescription: String = itemDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        var newItem: Item
        
        if trimmedDescription.count > 0 {
            newItem = Item(name: trimmedName, details: trimmedDescription)
        } else {
            newItem = Item(name: trimmedName, details: nil)
        }
    
        modelContext.insert(newItem)
        try? modelContext.save()
        
        onCreated(newItem)
        
        dismiss()
    }
}

#Preview {
    AddItemView { _ in }
}
