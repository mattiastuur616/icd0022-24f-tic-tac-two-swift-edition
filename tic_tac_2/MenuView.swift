//
//  GreetingView.swift
//  tic_tac_2
//
//  Created by Mattias Tüür on 22.11.2024.
//
import SwiftUI

struct MenuView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Tic Tac Two")
                NavigationLink(destination: GameBoardView()) {
                    Text("Play")
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
