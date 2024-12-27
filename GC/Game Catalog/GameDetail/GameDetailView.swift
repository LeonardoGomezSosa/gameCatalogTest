//
//  GameDetailView.swift
//  Game Catalog
//
//  Created by Leonardo Gómez Sosa on 27/12/24.
//


import SwiftUI
import CoreData

struct GameDetailView: View {
    @StateObject var viewModel: GameDetailViewModel
    @Environment(\.presentationMode) var presentationMode // To dismiss the view after deletion
    
    // Computed properties for each field's binding
    private var titleBinding: Binding<String> {
        Binding(
            get: { viewModel.game.title ?? "" },
            set: { viewModel.game.title = $0 }
        )
    }
    
    private var thumbnailBinding: Binding<String> {
        Binding(
            get: { viewModel.game.thumbnail ?? "" },
            set: { viewModel.game.thumbnail = $0 }
        )
    }
    
    private var genreBinding: Binding<String> {
        Binding(
            get: { viewModel.game.genre ?? "" },
            set: { viewModel.game.genre = $0 }
        )
    }
    
    private var platformBinding: Binding<String> {
        Binding(
            get: { viewModel.game.platform ?? "" },
            set: { viewModel.game.platform = $0 }
        )
    }
    
    private var publisherBinding: Binding<String> {
        Binding(
            get: { viewModel.game.publisher ?? "" },
            set: { viewModel.game.publisher = $0 }
        )
    }
    
    private var developerBinding: Binding<String> {
        Binding(
            get: { viewModel.game.developer ?? "" },
            set: { viewModel.game.developer = $0 }
        )
    }
    
    private var releaseDateBinding: Binding<String> {
        Binding(
            get: { viewModel.game.releaseDate ?? "" },
            set: { viewModel.game.releaseDate = $0 }
        )
    }
    
    private var gameURLBinding: Binding<String> {
        Binding(
            get: { viewModel.game.gameURL ?? "" },
            set: { viewModel.game.gameURL = $0 }
        )
    }

    init(game: LocalGame, context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: GameDetailViewModel(game: game, context: context))
    }

    var body: some View {
        Form {
            // Game Title
            TextField("Title", text: titleBinding)

            // Game Thumbnail
            AsyncImage(url: URL(string: thumbnailBinding.wrappedValue))
                .frame(width: 200, height: 200, alignment: .center)
                .cornerRadius(12)

            // Game Genre
            TextField("Genre", text: genreBinding)

            // Game Platform
            TextField("Platform", text: platformBinding)

            // Game Publisher
            TextField("Publisher", text: publisherBinding)

            // Game Developer
            TextField("Developer", text: developerBinding)

            // Game Release Date
            TextField("Release Date", text: releaseDateBinding)

            // Game URL
            TextField("Game URL", text: gameURLBinding)

            // Save Button
            Button("Save Changes") {
                viewModel.saveGame()
                presentationMode.wrappedValue.dismiss() // Dismiss the detail view
            }

            // Delete Button
            Button("Delete Game") {
                viewModel.deleteGame()
                presentationMode.wrappedValue.dismiss() // Dismiss after deletion
            }
            .foregroundColor(.red)
        }
        .navigationTitle("Game Details")
        .padding()
    }
}
