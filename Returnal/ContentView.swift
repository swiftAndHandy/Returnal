//
//  ContentView.swift
//  Returnal
//
//  Created by Andre Veltens on 01.12.25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject private var router: DeepLinkRouter
    
    @State private var qrCodePath: [Item] = []
    
    @State private var addItemIsPresented: Bool = false
    @State private var searchText: String = ""
    
    @Query(sort: [
        SortDescriptor(\Item.name)
    ]) var items: [Item]
    
    var filteredItems: [Item] {
        items
    }
    
    @State private var itemType: Filter.types = Filter.types.all
    
    var body: some View {
     
        NavigationStack(path: $qrCodePath) {
            VStack {
                if items.isEmpty {
                    NoItemsView(addItemIsPresented: $addItemIsPresented)
                } else if filteredItems.isEmpty {
                    NoFilteredItemsView()
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            NavigationLink(value: item) {
                                HStack {
                                    Text("\(item.name)")
                                    Spacer()
                                    VStack(alignment: .leading) {
                                        if let _ = item.debtor {
                                            Text("(verliehen)")
                                                .foregroundStyle(.red)
                                        }
                                        if item.qrCodeNeverScanned {
                                            Text("(ungescannt)")
                                                .foregroundStyle(.yellow)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Text(itemType.rawValue)
                }
            }
            .navigationTitle("Übersicht")
            .navigationDestination(for: Item.self) { item in
                ItemDetailsView(for: item)
            }
            .onChange(of: router.targetUUID) { _, newValue in
                guard let uuid = newValue else { return }
                qrCodePath = []
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    if let match = items.first(where: { $0.id == uuid}) {
                        if match.qrCodeNeverScanned {
                            match.qrCodeNeverScanned = false
                            try? modelContext.save()
                        }
                        qrCodePath.append(match)
                        router.targetUUID = nil
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Menu("Filter", systemImage: "line.3.horizontal.decrease") {
                        Picker("Filter", selection: $itemType) {
                            ForEach(Filter.types.allCases, id: \.self) { type in
                                Text(type.rawValue)
                                    .tag(type)
                            }
                        }
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
                AddItemView { newItem in
                    qrCodePath = []
                    qrCodePath.append(newItem)
                }
            }
        }
        
    }
}

#Preview {
    ContentView()
        .environmentObject(DeepLinkRouter())
}
