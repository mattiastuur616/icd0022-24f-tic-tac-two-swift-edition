//
//  SavedGamesView.swift
//  tic_tac_2
//
//  Created by Mattias Tüür on 02.12.2024.
//

import SwiftUI
import SwiftData

struct SavedGamesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [.init(\Game.date)], animation: .bouncy)
    private var games: [Game]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(games) { game in
                    NavigationLink(destination: GameDetailsView(game: game)) {
                        VStack(alignment: .leading) {
                            Text("Game with date: \(game.date.formatted())")
                                .font(.headline)
                            Text("Current player: \(game.currentPlayer)")
                                .font(.subheadline)
                        }
                    }
                }
                .onDelete(perform: deleteGame)
            }
            .navigationTitle("Saved games")
            .onAppear {
                print("Loaded games: \(games)")
            }
        }
    }
    
    private func deleteGame(at offsets: IndexSet) {
        for index in offsets {
            let game = games[index]
            modelContext.delete(game)
            do {
                try modelContext.save()
                print("Saved successfully")
            } catch {
                print("Error removing the game: \(error)")
            }
        }
    }
}

#Preview {
    SavedGamesView().modelContainer(for: Game.self)
}
