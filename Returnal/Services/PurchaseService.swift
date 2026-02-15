//
//  PurchaseService.swift
//  Returnal
//
//  Created by Andre Veltens on 10.12.25.
//

internal import Combine
import Foundation
import StoreKit

@MainActor
final class PurchaseService: ObservableObject {
    @Published var isProUnlocked: Bool = false
    
    private var products: [Product] = []
    
    init() {
        Task {
            await loadProducts()
            await updateEntitlements()
            observeTransactions()
        }
    }
    
    private func loadProducts() async {
        do {
            products = try await Product.products(for: ["com.boolproof.returnal.pro"])
        } catch {
            print("Couldn't load product: \(error.localizedDescription)")
        }
    }
    
    func purchasePro() async throws {
        guard let product = products.first else { return }
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            guard case .verified(let transaction) = verification else { return }
            await updateEntitlements()
            await transaction.finish()
        default:
            break
        }
    }
    
    private func observeTransactions() {
        Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await updateEntitlements()
                    await transaction.finish()
                }
            }
        }
    }
    
    func updateEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == "com.boolproof.returnal.pro" {
                isProUnlocked = true
                return
            }
        }
        isProUnlocked = false
    }
    
}
