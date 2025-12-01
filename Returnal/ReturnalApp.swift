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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Item.self)
    }
}
