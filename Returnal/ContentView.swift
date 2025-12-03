//
//  ContentView.swift
//  Returnal
//
//  Created by Andre Veltens on 01.12.25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: DeepLinkRouter
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var qrCodePath: [Item] = []
    
    @State private var addItemIsPresented: Bool = false
    @State private var searchQuery: String = ""
    
    @Query(sort: [
        SortDescriptor(\Item.name)
    ]) var items: [Item]
    
    var filteredItems: [Item] {
        switch itemType {
        case .all:
            return items
        case .borrowed:
            return items.filter { $0.debtor != nil}
        case .available:
            return items.filter { $0.debtor == nil}
        case .unscanned:
            return items.filter { $0.qrCodeNeverScanned }
        }
    }
    
    var finalItemList: [Item] {
        let base = filteredItems
        guard !searchQuery.isEmpty else { return base }
        return base.filter { $0.name.localizedCaseInsensitiveContains(searchQuery.trimmingCharacters(in: .whitespaces)) }
    }
    
    @State private var itemType: Filter.types = Filter.types.all
    
    var body: some View {
     
        NavigationStack(path: $qrCodePath) {
            VStack {
                if items.isEmpty {
                    NoItemsView(addItemIsPresented: $addItemIsPresented)
                } else if finalItemList.isEmpty {
                    NoFilteredItemsView()
                } else {
                    FilteredItemsView(items: finalItemList)
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
                ToolbarItem(placement: .bottomBar) {
                    TextField("Suche", text: $searchQuery)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 14)
                }
                
                Group {
                    ToolbarItem {
                        Menu("Filter", systemImage: itemType == .all ? "line.3.horizontal.decrease" : "line.3.horizontal.decrease") {
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
