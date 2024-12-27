//
//  GameDetailViewModel.swift
//  Game Catalog
//
//  Created by Leonardo Gómez Sosa on 27/12/24.
//


import Foundation
import CoreData
import Combine

class GameDetailViewModel: ObservableObject {
    @Published var game: LocalGame
    private var context: NSManagedObjectContext

    init(game: LocalGame, context: NSManagedObjectContext) {
        self.game = game
        self.context = context
    }

    // Save the game
    func saveGame() {
        do {
            try context.save()
        } catch {
            print("Failed to save game: \(error)")
        }
    }

    // Delete the game
    func deleteGame() {
        context.delete(game)
        do {
            try context.save()
        } catch {
            print("Failed to delete game: \(error)")
        }
    }
}
