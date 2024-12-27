//
//  Game.swift
//  Game Catalog
//
//  Created by Leonardo Gómez Sosa on 26/12/24.
//

import Foundation

struct Game: Identifiable, Codable {
    let id: Int
    let title: String
    let thumbnail: String
    let shortDescription: String
    let gameURL: String
    let genre: String
    let platform: String
    let publisher: String
    let developer: String
    let releaseDate: String
    let freeToGameProfileURL: String

    enum CodingKeys: String, CodingKey {
        case id, title, thumbnail, genre, platform, publisher, developer
        case shortDescription = "short_description"
        case gameURL = "game_url"
        case releaseDate = "release_date"
        case freeToGameProfileURL = "freetogame_profile_url"
    }
}
