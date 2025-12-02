//
//  DebtorView.swift
//  Returnal
//
//  Created by Andre Veltens on 02.12.25.
//

import SwiftUI

struct DebtorView: View {
    
    private var debtor: Borrower
    
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
    
    init(debtor: Borrower) {
        self.debtor = debtor
    }
    
}

#Preview {
    DebtorView(
        debtor: Borrower(firstName: "Klaus", lastName: "Kleber")
    )
}
