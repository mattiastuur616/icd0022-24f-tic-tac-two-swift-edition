//
//  StatsView.swift
//  tic_tac_2
//
//  Created by Mattias Tüür on 06.12.2024.
//

import SwiftUI

struct StatsView: View {
    @Binding var xWins1Player: Int
    @Binding var oWins1Player: Int
    @Binding var xWins2Player: Int
    @Binding var oWins2Player: Int
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("1 player games")
                .font(.title)
                .padding(8)
            HStack {
                Text("Wins of X: \(xWins1Player)")
                Text("Wins of O: \(oWins1Player)")
            }
            .font(.title2)
            
            Spacer()
            
            Text("2 player games")
                .font(.title)
                .padding(8)
            HStack {
                Text("Wins of X: \(xWins2Player)")
                Text("Wins of O: \(oWins2Player)")
            }
            .font(.title2)
            
            Spacer()
        }
        .onAppear {
            loadStats()
        }
    }
    
    private func loadStats() {
        if let savedXWins1Player = UserDefaults.standard.value(forKey: "xWins1Player") as? Int {
            xWins1Player = savedXWins1Player
        }
        if let savedOWins1Player = UserDefaults.standard.value(forKey: "oWins1Player") as? Int {
            oWins1Player = savedOWins1Player
        }
        if let savedXWins2Player = UserDefaults.standard.value(forKey: "xWins2Player") as? Int {
            xWins2Player = savedXWins2Player
        }
        if let savedOWins2Player = UserDefaults.standard.value(forKey: "oWins2Player") as? Int {
            oWins2Player = savedOWins2Player
        }
    }
}

struct StatsPreview: View {
    @State private var xWins1Player: Int = 0
    @State private var oWins1Player: Int = 0
    @State private var xWins2Player: Int = 0
    @State private var oWins2Player: Int = 0
    
    var body: some View {
        StatsView(xWins1Player: $xWins1Player, oWins1Player: $oWins1Player, xWins2Player: $xWins2Player, oWins2Player: $oWins2Player)
    }
}

#Preview {
    StatsPreview()
}
