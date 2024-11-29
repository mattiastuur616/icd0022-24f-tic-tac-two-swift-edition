//
//  GameSettingsView.swift
//  tic_tac_2
//
//  Created by Mattias Tüür on 22.11.2024.
//

import SwiftUI

struct GameSettingsView: View {
    @Binding var initialButtons: Int
    private let settingsKey = "initialButtons"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Game Settings")
                .font(.largeTitle)
                .padding(.top)
            
            Spacer()
            
            HStack {
                Text("Number of buttons:")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Stepper(value: $initialButtons, in: 4...10) {
                    Text("\(initialButtons)")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            Spacer()
            
            Button("Save Settings") {
                saveSettings()
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(10)
        }
        .padding()
        .onAppear {
            loadSettings()
        }
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(initialButtons, forKey: settingsKey)
        print("Settings saved: \(initialButtons) buttons per player")
    }
    
    private func loadSettings() {
        if let savedValue = UserDefaults.standard.value(forKey: settingsKey) as? Int {
            initialButtons = savedValue
            print("Settings loaded: \(initialButtons) buttons per player")
        }
    }
}

struct GameSettingsPreview: View {
    @State private var buttons = 4
    
    var body: some View {
        GameSettingsView(initialButtons: $buttons)
    }
}

#Preview("Settings Preview") {
    GameSettingsPreview()
}
