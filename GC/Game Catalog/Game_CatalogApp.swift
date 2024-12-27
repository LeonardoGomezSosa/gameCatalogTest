//
//  Game_CatalogApp.swift
//  Game Catalog
//
//  Created by Leonardo Gómez Sosa on 26/12/24.
//

import SwiftUI

@main
struct Game_CatalogApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            GameListView(context: persistenceController.container.viewContext)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
