//
//  BorrowerHistoryView.swift
//  Returnal
//
//  Created by Andre Veltens on 05.12.25.
//

import SwiftUI

struct BorrowerHistoryView: View {
    private var item: Item
    let sortedDebtors: [Borrower]
    
    var body: some View {
        NavigationStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(sortedDebtors.indices, id: \.self) { index in
                            let borrower = sortedDebtors[index]
                            VStack(alignment: .leading) {
                                Text("\(borrower.firstName) \(borrower.lastName)")
                                    .font(.headline)
                                HStack {
                                    Text("Entliehen am: \(borrower.dateOfBorrowing.formatted(date: .long, time: .omitted))")
                                }
                                
                                let returnDate = borrower.dateOfReturning?.formatted(date: .long, time: .omitted) ?? "ausstehend"
                                
                                Text("Rückgabe am: \(returnDate)")
                                
                                if let description = borrower.borrowedItemDetails {
                                    if !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        Text("""
                                        Beschreibung: 
                                        \(description)
                                        """)
                                        .padding(.top)
                                    }
                                }
                                
                                let promissedReturnDate = borrower.promissedDateOfReturning?.formatted(date: .long, time: .omitted) ?? nil
                                if let endDate = promissedReturnDate {
                                    Text("Rückgabe bis: \(endDate)")
//                                        .foregroundStyle(checkDeadlineExpiration(borrower: borrower))
                                }
                                
                                if index < sortedDebtors.count - 1 {
                                    Divider()
                                }
                            }
                            .padding(.bottom)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
            }
            .navigationTitle("Entleihverlauf für \(item.name)")
            .navigationBarTitleDisplayMode(.inline)
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
    
    init (for item: Item) {
        self.item = item
        self.sortedDebtors = item.debtors.sorted(by: { $0.dateOfBorrowing > $1.dateOfBorrowing })
    }
    
    func checkDeadlineExpiration(borrower: Borrower) -> Color {
        guard let dateOfReturning = borrower.dateOfReturning else {
            return .primary
        }
        
        let exceeded = borrower.promissedDateOfReturning.isExceeded(comparedTo: dateOfReturning)
        
        if exceeded {
            return .red
        }
        return .primary
    }
}

#Preview {
    BorrowerHistoryView(for: Item(name: "Trittleiter", debtors: [Borrower(firstName: "Simon", lastName: "Müller"), ]))
}
