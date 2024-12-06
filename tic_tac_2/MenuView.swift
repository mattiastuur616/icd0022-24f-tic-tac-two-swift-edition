//
//  GreetingView.swift
//  tic_tac_2
//
//  Created by Mattias Tüür on 22.11.2024.
//
import SwiftUI

struct MenuView: View {
    @State private var initialButtons: Int = 4
    @State private var xWins1Player: Int = 0
    @State private var oWins1Player: Int = 0
    @State private var xWins2Player: Int = 0
    @State private var oWins2Player: Int = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Tic Tac Two")
                    .font(.title)
                NavigationLink(destination: AIGameBoardView().modelContainer(for: Game.self)) {
                    Text("1 player")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .navigationBarTitle("Home", displayMode: .inline)
                NavigationLink(destination: GameBoardView().modelContainer(for: Game.self)) {
                    Text("2 player")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .navigationBarTitle("Home", displayMode: .inline)
                NavigationLink(destination: GameSettingsView(initialButtons: $initialButtons)) {
                    Text("Settings")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .navigationBarTitle("Home", displayMode: .inline)
                NavigationLink(destination: StatsView(xWins1Player: $xWins1Player, oWins1Player: $oWins1Player, xWins2Player: $xWins2Player, oWins2Player: $oWins2Player)) {
                    Text("Stats")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .navigationBarTitle("Home", displayMode: .inline)
            }
        }
    }
}

#Preview {
    MenuView()
}
