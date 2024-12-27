//
//  PersistenceController.swift
//  Game Catalog
//
//  Created by Leonardo Gómez Sosa on 26/12/24.
//

import CoreData
import SwiftUI

struct GameListView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContext = PersistenceController.preview.container.viewContext
        return GameListView(context: previewContext)
    }
}

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)

        // Add mock data for previews
        let viewContext = controller.container.viewContext
        for i in 0..<10 {
            let game = LocalGame(context: viewContext)
            game.id = Int64(i)
            game.title = "Game \(i)"
            game.genre = "Genre \(i)"
            game.thumbnail = "https://via.placeholder.com/150"
            game.shortdescription = "Description for game \(i)"
            game.gameURL = "https://example.com/game\(i)"
        }
        try? viewContext.save()
        return controller
    }()


    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "GameCatalog")
        
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    // MARK: Save Games to Local Storage
    func saveGames(_ games: [Game]) {
        let context = container.viewContext
        games.forEach { game in
            let entity = LocalGame(context: context)
            entity.id = Int64(game.id)
            entity.title = game.title
            entity.thumbnail = game.thumbnail
            entity.shortdescription = game.shortDescription
            entity.gameURL = game.gameURL
            entity.genre = game.genre
            entity.platform = game.platform
            entity.publisher = game.publisher
            entity.developer = game.developer
            entity.releaseDate = game.releaseDate
            entity.freeToGameProfileURL = game.freeToGameProfileURL
        }
        do {
            try context.save()
        } catch {
            print("Failed to save games: \(error)")
        }
    }

    // MARK: Fetch Games from Local Storage
    func fetchGames() -> [Game] {
        let context = container.viewContext
        let request: NSFetchRequest<LocalGame> = LocalGame.fetchRequest()

        do {
            let localGames = try context.fetch(request)
            return localGames.map { localGame in
                Game(
                    id: Int(localGame.id),
                    title: localGame.title ?? "",
                    thumbnail: localGame.thumbnail ?? "",
                    shortDescription: localGame.shortdescription ?? "",
                    gameURL: localGame.gameURL ?? "",
                    genre: localGame.genre ?? "",
                    platform: localGame.platform ?? "",
                    publisher: localGame.publisher ?? "",
                    developer: localGame.developer ?? "",
                    releaseDate: localGame.releaseDate ?? "",
                    freeToGameProfileURL: localGame.freeToGameProfileURL ?? ""
                )
            }
        } catch {
            print("Failed to fetch games: \(error)")
            return []
        }
    }

    // MARK: Delete a Game from Local Storage
    func deleteGame(by id: Int) {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<LocalGame> = LocalGame.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)

        do {
            if let localGame = try context.fetch(fetchRequest).first {
                context.delete(localGame)
                try context.save()
            }
        } catch {
            print("Failed to delete game: \(error)")
        }
    }

    // MARK: Update a Game in Local Storage
    func updateGame(game: Game) {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<LocalGame> = LocalGame.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", game.id)

        do {
            if let localGame = try context.fetch(fetchRequest).first {
                localGame.title = game.title
                localGame.thumbnail = game.thumbnail
                localGame.shortdescription = game.shortDescription
                localGame.gameURL = game.gameURL
                localGame.genre = game.genre
                localGame.platform = game.platform
                localGame.publisher = game.publisher
                localGame.developer = game.developer
                localGame.releaseDate = game.releaseDate
                localGame.freeToGameProfileURL = game.freeToGameProfileURL
                try context.save()
            }
        } catch {
            print("Failed to update game: \(error)")
        }
    }
}
