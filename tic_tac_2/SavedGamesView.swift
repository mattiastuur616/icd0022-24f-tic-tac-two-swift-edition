//
//  SavedGamesView.swift
//  tic_tac_2
//
//  Created by Mattias Tüür on 02.12.2024.
//

import SwiftUI
import SwiftData

struct SavedGamesView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [.init(\Game.date)], animation: .bouncy)
    private var games: [Game]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(games) { game in
                    Button(action: { loadGame(game: game) }) {
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
        }
    }
    
    private func loadGame(game: Game) {
        UserDefaults.standard.set(game.currentPlayer, forKey: "loadCurrentPlayer")
        UserDefaults.standard.set(game.board, forKey: "loadBoard")
        UserDefaults.standard.set(game.grid, forKey: "loadGrid")
        UserDefaults.standard.set(game.prevState, forKey: "loadPrevState")
        UserDefaults.standard.set(game.xButtons, forKey: "loadXButtons")
        UserDefaults.standard.set(game.oButtons, forKey: "loadOButtons")
        UserDefaults.standard.set(game.turnAmount, forKey: "loadTurnAmount")
        UserDefaults.standard.set(game.gridCenterX, forKey: "loadGridCenterX")
        UserDefaults.standard.set(game.gridCenterY, forKey: "loadGridCenterY")
        presentationMode.wrappedValue.dismiss()
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
