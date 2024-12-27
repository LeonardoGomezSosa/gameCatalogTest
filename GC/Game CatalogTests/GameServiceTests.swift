//
//  GameServiceTests.swift
//  Game Catalog
//
//  Created by Leonardo Gómez Sosa on 27/12/24.
//


import XCTest
import Combine
@testable import Game_Catalog

final class GameServiceTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }

    func testFetchGamesSuccess() {
        // Arrange
        let expectation = self.expectation(description: "Fetch games from API")
        let gameService = GameService.shared
        var fetchedGames: [Game] = []

        // Act
        gameService.fetchGames()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Fetch failed with error: \(error)")
                }
            }, receiveValue: { games in
                fetchedGames = games
                expectation.fulfill()
            })
            .store(in: &cancellables)

        // Wait for async task
        waitForExpectations(timeout: 5.0)

        // Assert
        XCTAssertFalse(fetchedGames.isEmpty, "Fetched games should not be empty")
    }
}
