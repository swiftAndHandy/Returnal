//
//  ContentView.swift
//  Returnal
//
//  Created by Andre Veltens on 01.12.25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    
    @State private var addItemIsPresented: Bool = false
    
    var body: some View {
     
        NavigationStack {
            VStack {
                List {
                    
                }
            }
            .navigationTitle("Übersicht")
            .toolbar {
                ToolbarItem {
                    Button {
                        
                    } label: {
                        Label("Filtern", systemImage: "line.3.horizontal.decrease")
                    }
                }
                ToolbarItem {
                    Button {
                        addItemIsPresented = true
                    } label: {
                        Label("Neuer Gegenstand", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $addItemIsPresented) {
                AddItemView()
            }
        }
        
    }
}

#Preview {
    ContentView()
}
