//
//  GreetingView.swift
//  tic_tac_2
//
//  Created by Mattias Tüür on 22.11.2024.
//
import SwiftUI

struct MenuView: View {
    @State private var initialButtons: Int = 4
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Tic Tac Two")
                    .font(.title)
                NavigationLink(destination: AIGameBoardView()) {
                    Text("1 player")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .navigationBarTitle("Home", displayMode: .inline)
                NavigationLink(destination: GameBoardView()) {
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
            }
        }
    }
}

#Preview {
    MenuView()
}
