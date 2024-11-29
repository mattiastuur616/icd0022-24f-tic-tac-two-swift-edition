//
//  ContentView.swift
//  tic_tac_2
//
//  Created by Mattias Tüür on 22.11.2024.
//

import SwiftUI

enum Player: String, Codable {
    case x = "X"
    case o = "O"
}

struct GameState: Codable {
    let currentPlayer: Player
    let board: [[Player?]]
    let grid: [[Int]]
    let gridCenter: [Int]
    let activeButton: [Int]
    let gameState: String
    let winner: Player?
    let isDraw: Bool
    let winningCells: Set<[Int]>
}

struct GameBoardView: View {
    
    @State private var currentPlayer: Player = .x
    @State private var board: [[Player?]] = Array(repeating: Array(repeating: nil, count: 5), count: 5)
    @State private var grid = Array(arrayLiteral: (1, 1), (1, 2), (1, 3), (2, 1), (2, 2), (2, 3), (3, 1), (3, 2), (3, 3))
    @State private var prevCenter = (0, 0)
    @State private var gridCenter = (2, 2)
    @State private var activeButton = (6, 6)
    @State private var gameState = "add"
    @State private var prevState = "add"
    @State private var turnAmount = 0
    @State private var winner: Player?
    @State private var isDraw: Bool = false
    @State private var winningCells: Set<[Int]> = []
    
    private let saveKey = "tic_tac_two_state"
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Tic-Tac-Two")
                .font(.largeTitle)
                .padding(.vertical)
            
            Spacer()
            
            Text("Player \(currentPlayer.rawValue.uppercased())'s turn")
                .font(.title2)
                .foregroundColor(currentPlayer == .x ? .red : .blue)
            
            ForEach(0..<5) { row in
                HStack(spacing: 10) {
                    ForEach(0..<5) { column in
                        Button(
                            action: {
                                if (gameState == "add" && board[row][column] == currentPlayer && turnAmount >= 4) {
                                    prevState = gameState
                                    gameState = "move"
                                    activeButton = (row, column)
                                    turnAmount += 1
                                } else if (gameState == "move" && turnAmount >= 4) {
                                    prevState = gameState
                                    moveButton(row, column)
                                    turnAmount += 1
                                } else if (gameState == "add") {
                                    if board[row][column] == nil {
                                        prevState = gameState
                                        board[row][column] = currentPlayer
                                        currentPlayer =
                                            currentPlayer == .x ? .o : .x
                                        checkForWinner()
                                        turnAmount += 1
                                    }
                                } else if (gameState == "grid" && turnAmount >= 4) {
                                    prevState = gameState
                                    changeGridLocation(row, column)
                                    turnAmount += 1
                                }
                            },
                            label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(
                                            currentColor(row, column)
                                        )
                                        .frame(width: 60, height: 60)
                                        .shadow(radius: 5)
                                    Text(board[row][column]?.rawValue ?? " ")
                                        .font(.largeTitle)
                                        .foregroundColor(board[row][column] == .x ? .red :(board[row][column] == .o ? .blue : .white))
                                }
                            }
                        )
                        .disabled(disableButtons(row, column))
                        .scaleEffect(
                            winningCells.contains([row, column]) ? 1.2 : 1.0
                        )
                        .animation(
                            .easeInOut(duration: 1),
                            value: winningCells.contains([row, column])
                        )
                    }
                }
            }
            
            HStack {
                Button("Grid", action: changeStateToGrid)
                    .foregroundColor(.white)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(gameState == "add" && prevState != "grid" && turnAmount >= 4 ? Color.blue : Color.gray)
                    .cornerRadius(10)
                    .disabled(winner != nil || gameState == "move" || prevState == "grid" || turnAmount < 4)
            }
            .padding()

            
            Spacer()
            
            if let winner = winner {
                Text("Player \(winner.rawValue) wins!")
                    .foregroundColor(.green)
                    .scaleEffect(2)
                    .animation(.linear(duration: 0.5), value: winner)
                    .padding(.vertical)
            } else if isDraw {
                Text("It's a draw!")
                    .foregroundColor(.orange)
                    .scaleEffect(2)
                    .animation(.linear(duration: 0.5), value: isDraw)
                    .padding(.vertical)
            }
            
            Spacer()
            
            Button("Reset Game", action: resetGame)
                .foregroundColor(.white)
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
        }
        .padding()
    }
    
    func changeStateToGrid() {
        if (gameState == "add") {
            gameState = "grid"
        } else {
            gameState = "add"
        }
    }
    
    func disableButtons(_ row: Int, _ column: Int) -> Bool {
        return (gameState == "add" && (board[row][column] != nil && board[row][column] != currentPlayer)) ||
        winner != nil ||
        ((row, column) == gridCenter && gameState == "grid") ||
        !grid.contains(where: { $0 == (row, column) }) ||
        (gameState == "grid" && (row == 0 || row == 4 || column == 0 || column == 4))
        || (gameState == "move" && board[row][column] != nil && activeButton != (row, column))
    }
    
    func changeGridLocation(_ row: Int, _ col: Int) {
        prevCenter = gridCenter
        gridCenter = (row, col)
        let rowDif = prevCenter.0 - gridCenter.0
        let colDif = prevCenter.1 - gridCenter.1
        for i in grid.indices {
            grid[i] = (grid[i].0 - rowDif, grid[i].1 - colDif)
        }
        gameState = "add"
        currentPlayer =
            currentPlayer == .x ? .o : .x
        checkForWinner()
    }
    
    func moveButton(_ row: Int, _ col: Int) {
        if ((row, col) == activeButton) {
            activeButton = (6,6)
            gameState = "add"
        } else if (board[row][col] == nil) {
            board[row][col] = currentPlayer
            board[activeButton.0][activeButton.1] = nil
            activeButton = (6,6)
            gameState = "add"
            currentPlayer =
                currentPlayer == .x ? .o : .x
            checkForWinner()
        }
    }
    
    func checkForWinner() {
        //rows
        for row in stride(from: 0, to: 9, by: 3) {
            if let player = board[grid[row].0][grid[row].1],
               player == board[grid[row+1].0][grid[row+1].1],
               player == board[grid[row+2].0][grid[row+2].1]
            {
                winner = player
                winningCells = Set([[grid[row].0, grid[row].1], [grid[row+1].0, grid[row+1].1], [grid[row+2].0, grid[row+2].1]])
                return
            }
        }
        //columns
        for col in 0..<3 {
            if let player = board[grid[col].0][grid[col].1],
               player == board[grid[col+3].0][grid[col+3].1],
               player == board[grid[col+6].0][grid[col+6].1]
            {
                winner = player
                winningCells = Set([[grid[col].0, grid[col].1], [grid[col+3].0, grid[col+3].1], [grid[col+6].0, grid[col+6].1]])
                return
            }
        }
        //diag1
        if let player = board[grid[0].0][grid[0].1],
           player == board[grid[4].0][grid[4].1],
           player == board[grid[8].0][grid[8].1]
        {
            winner = player
            winningCells = Set([[grid[0].0, grid[0].1], [grid[4].0, grid[4].1], [grid[8].0, grid[8].1]])
            return
        }
        //diag2
        if let player = board[grid[2].0][grid[2].1],
           player == board[grid[4].0][grid[4].1],
           player == board[grid[6].0][grid[6].1]
        {
            winner = player
            winningCells = Set([[grid[2].0, grid[2].1], [grid[4].0, grid[4].1], [grid[6].0, grid[6].1]])
            return
        }
        
        if !board.flatMap({$0}).contains(nil) {
            isDraw = true
        }
    }
    
    func resetGame() {
        currentPlayer = .x
        board = Array(repeating: Array(repeating: nil, count: 5), count: 5)
        winningCells = []
        winner = nil
        grid = Array(arrayLiteral: (1, 1), (1, 2), (1, 3), (2, 1), (2, 2), (2, 3), (3, 1), (3, 2), (3, 3))
        gridCenter = (2, 2)
    }
    
    func currentColor(_ row: Int, _ col: Int) -> Color {
        if (activeButton == (row, col) && gameState == "move") {
            return .green
        }
        if grid.contains(where: { $0 == (row, col) }) && 0 < row && row < 4 && 0 < col && col < 4 && gridCenter != (row, col) && gameState == "grid" {
                return .purple
            }
        if grid.contains(where: { $0 == (row, col) }) {
            return .yellow
        }
        return .gray
    }
    
    func saveGame() {
        var gridList = [[Int]]()
        for button in grid {
            let el = [button.0, button.1]
            gridList.append(el)
        }
        
        let gameState = GameState(
            currentPlayer: currentPlayer,
            board: board,
            grid: gridList,
            gridCenter: [gridCenter.0, gridCenter.1],
            activeButton: [activeButton.0, activeButton.1],
            gameState: gameState,
            winner: winner,
            isDraw: isDraw,
            winningCells: winningCells
        )
        
        if let data = try? JSONEncoder().encode(gameState) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }
    
    func loadGameState() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return }
        do {
            var gridTuple = Array<(Int, Int)>()
            
            let state = try JSONDecoder().decode(GameState.self, from: data)
            for button in state.grid {
                gridTuple.append((button[0], button[1]))
            }
            currentPlayer = state.currentPlayer
            board = state.board
            grid = gridTuple
            gridCenter = (state.gridCenter[0], state.gridCenter[1])
            activeButton = (state.activeButton[0], state.activeButton[1])
            gameState = state.gameState
            winner = state.winner
            isDraw = state.isDraw
            winningCells = state.winningCells
        } catch {
            print("Failed to load game state: \(error)")
        }
    }
}


#Preview("Preview 1") {
    GameBoardView()
}
