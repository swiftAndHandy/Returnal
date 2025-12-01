//
//  ReturnalApp.swift
//  Returnal
//
//  Created by Andre Veltens on 01.12.25.
//

import SwiftData
import SwiftUI

@main
struct ReturnalApp: App {
    
    @StateObject private var router = DeepLinkRouter()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(router)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
        .modelContainer(for: Item.self)
    }
    
    func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let uuidString = components.queryItems?.first(where: { $0.name == "uuid" })?.value,
              let uuid: UUID = UUID(uuidString: uuidString)
        else {
            print("Fehler beim Parsen der UUID-URL.")
            return
        }
        
        router.targetUUID = uuid
    }
}
