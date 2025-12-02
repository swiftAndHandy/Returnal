//
//  DebtorView.swift
//  Returnal
//
//  Created by Andre Veltens on 02.12.25.
//

import SwiftUI

struct DebtorView: View {
    
    private var debtor: Borrower
    private var itemName: String
    
    var body: some View {
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
                    let subject = "Rückgabe von \(itemName)"
                    let encoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? subject
                    
                    HStack {
                        Text("E-Mail:")
                        Link(email, destination: URL(string: "mailto:\(email)?subject=\(encoded)")!)
                    }
                    .font(.subheadline)
                }
                if let phoneNumber = debtor.phoneNumber {
                    let cleanedPhoneNumber = phoneNumber.filter("0123456789+".contains)
                    HStack {
                        Text("Telefon:")
                        Link(phoneNumber, destination: URL(string: "tel:\(cleanedPhoneNumber)")!)
                    }
                    .font(.subheadline)
                }
            }
        }
        Divider()
    }
    
    init(debtor: Borrower, itemName: String) {
        self.debtor = debtor
        self.itemName = itemName
    }
    
}

#Preview {
    DebtorView(
        debtor: Borrower(firstName: "Klaus", lastName: "Kleber"),
        itemName: "Rohrzange"
    )
}
