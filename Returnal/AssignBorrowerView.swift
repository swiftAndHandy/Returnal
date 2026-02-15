//
//  AssignBorrowerView.swift
//  Returnal
//
//  Created by Andre Veltens on 01.12.25.
//

import Contacts
import SwiftData
import SwiftUI

struct AssignBorrowerView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Bindable var item: Item
    
    @State private var borrower: Borrower = Borrower(firstName: "", lastName: "", address: Address())
    @State private var showContactPicker = false
    @State private var returningDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    @State private var returningDateIsSet: Bool = false
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Rückgabevereinbarung:") {
                    HStack {
                        Text("Rückgabedatum festlegen?")
                        Spacer()
                        Toggle("Rückgabe geplant", isOn: $returningDateIsSet)
                            .labelsHidden()
                    }
                    if returningDateIsSet {
                        DatePicker(
                            "Rückgabedatum",
                            selection: $returningDate,
                            in: Date()...,
                            displayedComponents: [.date]
                                )
                        .datePickerStyle(.compact)
                    }
                }
                Section("Pflichtangaben") {
                    TextField("Vorname", text: $borrower.firstName)
                        .textInputAutocapitalization(.words)
                    TextField("Nachname", text: $borrower.lastName)
                        .textInputAutocapitalization(.words)
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
                    .textInputAutocapitalization(.never)
                }
                Section("Adresse (optional)") {
                    TextField("Straße", text: Binding(
                        get: { borrower.address?.street ?? "" },
                        set: { borrower.address?.street = $0 }
                    ))
                    .textInputAutocapitalization(.words)
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
                        .autocapitalization(.words)
                    }
                    TextField("Land", text: Binding(
                        get: { borrower.address?.country ?? "" },
                        set: { borrower.address?.country = $0 }
                    ))
                }
            }
            .autocorrectionDisabled()
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
                ToolbarItem(placement: .bottomBar) {
                    VStack {
                        Button {
                            showContactPicker = true
                        } label: {
                            HStack {
                                Image(systemName: "person.crop.circle.badge.plus")
                                Text("Kontakt auswählen")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .sheet(isPresented: $showContactPicker) {
                            ContactPickerView { contact in
                                borrower.firstName = contact.givenName
                                borrower.lastName = contact.familyName
                                
                                if let phoneNumber = contact.phoneNumbers.first?.value as? CNPhoneNumber {
                                    borrower.phoneNumber = phoneNumber.stringValue
                                } else {
                                    borrower.phoneNumber = nil
                                }
                                
                                if let emailAddress = contact.emailAddresses.first?.value as? String {
                                    borrower.email = emailAddress
                                } else {
                                    borrower.email = nil
                                }
                                
                                if let postal = contact.postalAddresses.first?.value {
                                    borrower.address?.street = postal.street
                                    borrower.address?.city = postal.city
                                    borrower.address?.zipCode = postal.postalCode
                                    borrower.address?.country = postal.country
                                } else {
                                    borrower.address = nil
                                }
                            }
                        }
                    }
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
        
        let trimmedItemDetails = item.details?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var address: Address?
        
        if trimmedStreet == nil && trimmedZIPCode == nil && trimmedCity == nil && trimmedCountry == nil {
            address = nil
        } else {
            address = Address(street: trimmedStreet, zipCode: trimmedZIPCode, city: trimmedCity, country: trimmedCountry)
        }
          
        item.debtors.append(
            Borrower(
                firstName: trimmedFirstName,
                lastName: trimmedLastName,
                phoneNumber: trimmedPhoneNumber,
                email: trimmedEMail,
                address: address,
                borrowedItemDetails: trimmedItemDetails,
                promissedDateOfReturning: returningDateIsSet ? returningDate : nil
            )
        )
        
        item.isBorrowed = true
        
        try? modelContext.save()
        
        dismiss()
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Borrower.self, configurations: config)
        let example = Borrower(firstName: "", lastName: "")
        return AssignBorrowerView(item: Item(name: "Kneifzange", debtors: [example]))
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
