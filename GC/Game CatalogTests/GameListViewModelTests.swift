//
//  GameListViewModelTests.swift
//  Game Catalog
//
//  Created by Leonardo Gómez Sosa on 27/12/24.
//


import XCTest
import CoreData
@testable import Game_Catalog

final class GameListViewModelTests: XCTestCase {
    var viewModel: GameListViewModel!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()

        // Set up in-memory Core Data stack
        let persistentContainer = NSPersistentContainer(name: "YourCoreDataModelName")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { _, error in
            XCTAssertNil(error, "Error loading in-memory store: \(error?.localizedDescription ?? "")")
        }
        context = persistentContainer.viewContext

        // Initialize ViewModel with context
        viewModel = GameListViewModel(context: context)
    }

    override func tearDown() {
        viewModel = nil
        context = nil
        super.tearDown()
    }

    func testFetchGamesIfNeededStorage() {
        // Arrange: Create and save a sample game to the in-memory Core Data store
        let game = LocalGame(context: context)
        game.id = 1
        game.title = "Test Game"
        game.genre = "RPG"

        do {
            try context.save()
        } catch {
            XCTFail("Failed to save game: \(error.localizedDescription)")
        }

        // Act: Call the method that loads games from local storage
        viewModel.loadGamesFromLocalStorage()

        // Assert: Verify that the game is loaded into the ViewModel
        XCTAssertEqual(viewModel.games.count, 1, "There should be one game in the local storage")
        XCTAssertEqual(viewModel.games.first?.title, "Test Game", "Game title should match")
    }

    func testFilterGames() {
        // Arrange: Create and save multiple games to the in-memory Core Data store
        let game1 = LocalGame(context: context)
        game1.id = 1
        game1.title = "Test Game"
        game1.genre = "RPG"

        let game2 = LocalGame(context: context)
        game2.id = 2
        game2.title = "Another Game"
        game2.genre = "Shooter"

        do {
            try context.save()
        } catch {
            XCTFail("Failed to save games: \(error.localizedDescription)")
        }

        // Act: Load games and apply a search filter
        viewModel.loadGamesFromLocalStorage()
        viewModel.searchText = "RPG" // Set search text to filter by genre

        // Assert: Verify that only the "RPG" game is in the filtered list
        XCTAssertEqual(viewModel.filteredGames.count, 1, "Filtered games should contain one game")
        XCTAssertEqual(viewModel.filteredGames.first?.title, "Test Game", "Filtered game title should match")
    }
}
