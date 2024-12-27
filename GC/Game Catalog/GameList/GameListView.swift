//
//  GameListView.swift
//  Game Catalog
//
//  Created by Leonardo Gómez Sosa on 26/12/24.
//
import SwiftUI
import CoreData

struct GameListView: View {
    @StateObject private var viewModel: GameListViewModel

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: GameListViewModel(context: context))
    }

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                TextField("Search by title or genre...", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // List Content
                VStack {
                    if viewModel.isLoading {
                        ProgressView("Loading games...")
                            .padding()
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack {
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                            Button("Retry") {
                                viewModel.fetchGamesIfNeeded()
                            }
                            .padding()
                        }
                    } else if viewModel.filteredGames.isEmpty {
                        Text("No games found matching your search.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        List(viewModel.filteredGames) { game in
                            NavigationLink(
                                destination: GameDetailView(game: game, context: viewModel.context)
                            ) {
                                gameRow(for: game)
                            }.onDisappear( perform: { viewModel.loadGamesFromLocalStorage() } )
                        }
                    }
                }
                .navigationTitle("Games")
                .onAppear {
                    viewModel.fetchGamesIfNeeded()
                }
            }
        }
    }

    // Separate the row view logic for better readability and compiler optimization
    private func gameRow(for game: LocalGame) -> some View {
        HStack {
            // Thumbnail
            AsyncImage(url: URL(string: game.thumbnail ?? "")) { phase in
                switch phase {
                case .empty:
                    Color.gray
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                case .failure:
                    Color.gray
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                @unknown default:
                    Color.gray
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                }
            }

            // Game Details
            VStack(alignment: .leading) {
                Text(game.title ?? "Untitled")
                    .font(.headline)
                Text(game.genre ?? "Unknown Genre")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
