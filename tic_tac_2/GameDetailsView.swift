//
//  GameDetailsView.swift
//  tic_tac_2
//
//  Created by Mattias Tüür on 02.12.2024.
//

import SwiftUI

struct GameDetailsView: View {
    @Bindable var game: Game
    
    var body: some View {
        VStack {
            Text("Details about game")
                .font(.largeTitle)
            Text("Date: \(game.date.formatted())")
            Text("Current player: \(game.currentPlayer)")
            Spacer()
        }
        .padding()
    }
}
