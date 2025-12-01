//
//  AssignBorrowerView.swift
//  Returnal
//
//  Created by Andre Veltens on 01.12.25.
//

import SwiftData
import SwiftUI

struct AssignBorrowerView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var item: Item
    
    @State private var borrower: Borrower = Borrower(firstName: "", lastName: "")
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Pflichtangaben") {
                    TextField("Vorname", text: $borrower.firstName)
                    TextField("Nachname", text: $borrower.lastName)
                }
                Section("Adresse (optional)") {
                    
                }
            }
            .navigationTitle("Entleiher zuweisen")
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
                        saveBorrower()
                    } label: {
                        Label("Speichern", systemImage: "checkmark")
                    }
                    .disabled(saveDisabled())
                }
            }
        }
    }
    
    func saveDisabled() -> Bool {
        return borrower.firstName.trimmingCharacters(in: .whitespaces).count < 3 || borrower.lastName.trimmingCharacters(in: .whitespaces).count < 3
    }
    
    func saveBorrower() {
        let trimmedFirstName = borrower.firstName.trimmingCharacters(in: .whitespaces)
        let trimmedLastName = borrower.lastName.trimmingCharacters(in: .whitespaces)
        
        item.debtor = Borrower(firstName: trimmedFirstName, lastName: trimmedLastName)
        
        dismiss()
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Borrower.self, configurations: config)
        let example = Borrower(firstName: "", lastName: "")
        return AssignBorrowerView(item: Item(name: "Kneifzange", debtor: example))
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
