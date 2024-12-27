//
//  GameListViewModel.swift
//  Game Catalog
//
//  Created by Leonardo Gómez Sosa on 26/12/24.
//

import Combine
import SwiftUI
import CoreData

class GameListViewModel: ObservableObject {
    @Published var games: [LocalGame] = [] // Core Data-backed games
    @Published var filteredGames: [LocalGame] = [] // Filtered list for search
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = "" {
        didSet {
            filterGames()
        }
    }

    private var cancellables = Set<AnyCancellable>()
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        loadGamesFromLocalStorage()
    }


    func loadGamesFromLocalStorage() {
        let fetchRequest: NSFetchRequest<LocalGame> = LocalGame.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \LocalGame.title, ascending: true)]

        do {
            let localGames = try context.fetch(fetchRequest)
            games = localGames
            filteredGames = localGames
        } catch {
            errorMessage = "Failed to fetch games from local storage: \(error.localizedDescription)"
        }
    }

    // Fetch games from API if local storage is empty
    func fetchGamesIfNeeded() {
        guard games.isEmpty else { return }

        isLoading = true
        GameService.shared.fetchGames()
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] fetchedGames in
                guard let self = self else { return }
                self.saveGamesToLocalStorage(fetchedGames)
                self.loadGamesFromLocalStorage()
            })
            .store(in: &cancellables)
    }

    // Save fetched games to Core Data
    private func saveGamesToLocalStorage(_ games: [Game]) {
        let fetchRequest: NSFetchRequest<LocalGame> = LocalGame.fetchRequest()

        for game in games {
            // Check if the game already exists
            fetchRequest.predicate = NSPredicate(format: "id == %d", game.id)
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.isEmpty {
                    // If not found, create a new entry
                    let localGame = LocalGame(context: context)
                    localGame.id = Int64(game.id)
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
                }
            } catch {
                errorMessage = "Failed to check for duplicates: \(error.localizedDescription)"
            }
        }

        do {
            try context.save()
        } catch {
            errorMessage = "Failed to save games to local storage: \(error.localizedDescription)"
        }
    }


    // Filter games based on search text
    private func filterGames() {
        if searchText.isEmpty {
            filteredGames = games
        } else {
            filteredGames = games.filter {
                ($0.title?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                ($0.genre?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    func deleteGame(_ game: LocalGame) {
        if let index = games.firstIndex(of: game) {
            games.remove(at: index)
            filteredGames.removeAll { $0.id == game.id }

            // Delete from Core Data as well
            context.delete(game)
            do {
                try context.save()
            } catch {
                errorMessage = "Failed to delete game: \(error)"
            }
        }
    }

}
