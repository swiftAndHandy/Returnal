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
    
    @State private var borrower: Borrower = Borrower(firstName: "", lastName: "", address: Address())
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Pflichtangaben") {
                    TextField("Vorname", text: $borrower.firstName)
                    TextField("Nachname", text: $borrower.lastName)
                }
                Section("Kontakt (optional)") {
                    TextField("Telefon", text: Binding(
                        get: { borrower.phoneNumber ?? "" },
                        set: { borrower.phoneNumber = $0 }
                    ))
                    .keyboardType(.phonePad)
                    TextField("E-Mail", text: Binding(
                        get: { borrower.email ?? "" },
                        set: { borrower.email = $0 }
                    ))
                    .keyboardType(.emailAddress)
                }
                Section("Adresse (optional)") {
                    TextField("Straße", text: Binding(
                        get: { borrower.address?.street ?? "" },
                        set: { borrower.address?.street = $0 }
                    ))
                    HStack {
                        TextField("PLZ", text: Binding(
                            get: { borrower.address?.zipCode ?? "" },
                            set: { borrower.address?.zipCode = $0 }
                        ))
                        .keyboardType(.numberPad)
                        TextField("Ort", text: Binding(
                            get: { borrower.address?.city ?? "" },
                            set: { borrower.address?.city = $0 }
                        ))
                    }
                    TextField("Land", text: Binding(
                        get: { borrower.address?.country ?? "" },
                        set: { borrower.address?.country = $0 }
                    ))
                }
            }
            .scrollBounceBehavior(.basedOnSize)
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
        
        let trimmedPhoneNumber = borrower.phoneNumber?.trimmingCharacters(in: .whitespaces)
        let trimmedEMail = borrower.email?.trimmingCharacters(in: .whitespaces)
        
        let trimmedStreet = borrower.address?.street?.trimmingCharacters(in: .whitespaces)
        let trimmedZIPCode = borrower.address?.zipCode?.trimmingCharacters(in: .whitespaces)
        let trimmedCity = borrower.address?.city?.trimmingCharacters(in: .whitespaces)
        let trimmedCountry = borrower.address?.country?.trimmingCharacters(in: .whitespaces)
        
        var address: Address?
        
        if trimmedStreet == nil && trimmedZIPCode == nil && trimmedCity == nil && trimmedCountry == nil {
            address = nil
        } else {
            address = Address(street: trimmedStreet, zipCode: trimmedZIPCode, city: trimmedCity, country: trimmedCountry)
        }
          
        item.debtor = Borrower(firstName: trimmedFirstName, lastName: trimmedLastName, phoneNumber: trimmedPhoneNumber, email: trimmedEMail, address: address)
        
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
