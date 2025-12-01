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
    @State private var itemDescription: String = "Farbe, Größe, Zustand etc."
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Pflichtangaben") {
                    TextField("Name des Gegenstands", text: $itemName)
                }
                Section("Ergänzende Angaben") {
                    TextEditor(text: $itemDescription)
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
                        let newItem = Item(name: itemName, details: itemDescription)
                        modelContext.insert(newItem)
                        
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
}

#Preview {
    AddItemView()
}
