//
//  UpgradeToProView.swift
//  Returnal
//
//  Created by Andre Veltens on 10.12.25.
//

import SwiftUI

struct UpgradeToProView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var purchaseService: PurchaseService
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Returnal Pro freischalten")
                .font(.title2).bold()
            Text("""
                 Verwalte unbegrenzte Gegenstände, drucke QR-Codes und behalte die volle Kontrolle über deine verliehenen Gegenstände. 
                 
                 Alles in einer App. 
                 """)
            .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                Text("Nur **0,99 € einmalig.**")
                    .font(.title2).bold()
                Text("Lifetime-Zugang zu allen Pro-Funktionen")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical)
            
            VStack(spacing: 16) {
                Button {
                    Task {
                        try? await purchaseService.purchasePro()
                    }
                } label: {
                    HStack {
                        Image(systemName: "cart.fill")
                        Text("Returnal Pro kaufen")
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Kauf wiederherstellen") {
                    Task {
                        await purchaseService.updateEntitlements()
                    }
                }
                
                if #available(iOS 26.0, *) {
                    Button("Returnal Basic weiter nutzen", role: .close) {
                        dismiss()
                    }
                    .foregroundStyle(.red)
                    .buttonStyle(.bordered)
                } else {
                    Button("Returnal Basic weiter nutzen", role: .cancel) {
                        dismiss()
                    }
                    .foregroundStyle(.red)
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
    }
}

#Preview {
    UpgradeToProView()
}
