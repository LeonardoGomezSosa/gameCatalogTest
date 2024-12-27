//
//  GameService.swift
//  Game Catalog
//
//  Created by Leonardo Gómez Sosa on 26/12/24.
//


import Foundation
import Combine

class GameService {
    static let shared = GameService()

    func fetchGames() -> AnyPublisher<[Game], Error> {
        guard let url = URL(string: "https://www.freetogame.com/api/games") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Game].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

