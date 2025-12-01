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
    @State private var searchText: String = ""
    
    @Query(sort: [
        SortDescriptor(\Item.name)
    ]) var items: [Item]
    
    var body: some View {
     
        NavigationStack {
            VStack {
                List {
                    ForEach(items) { item in
                        NavigationLink(value: item) {
                            Text("Item: \(item.name)")
                        }
                    }
                }
            }
            .navigationTitle("Übersicht")
            .navigationDestination(for: Item.self) { item in
                ItemDetailsView(for: item)
            }
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
