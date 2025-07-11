//
//  ContentView.swift
//  tic_tac_2
//
//  Created by Mattias Tüür on 22.11.2024.
//

import SwiftUI
import SwiftData

enum Player: String {
    case x = "X"
    case o = "O"
}

struct GameBoardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [.init(\Game.date)], animation: .bouncy)
    private var games: [Game]
    
    @State private var currentPlayer: Player = .x
    @State private var board: [[Player?]] = Array(repeating: Array(repeating: nil, count: 5), count: 5)
    @State private var grid = Array(arrayLiteral: (1, 1), (1, 2), (1, 3), (2, 1), (2, 2), (2, 3), (3, 1), (3, 2), (3, 3))
    @State private var prevCenter = (0, 0)
    @State private var gridCenter = (2, 2)
    @State private var activeButton = (6, 6)
    
    @State private var gameState = "add"
    @State private var prevState = "begin"
    
    @State private var turnAmount = 0
    @State private var winner: Player?
    @State private var isDraw: Bool = false
    @State private var winningCells: Set<[Int]> = []
    
    @State private var xButtons: Int = 4
    @State private var oButtons: Int = 4
        
    private let settingsKey = "initialButtons"
    private let saveKey = "tic_tac_two_state"
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            if isLandscape {
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        VStack(spacing: 5) {
                            Text("Tic-Tac-Two")
                                .font(.largeTitle)
                                .padding(.vertical)
                            Text("X buttons: \(xButtons)")
                            Text("O buttons: \(oButtons)")
                            
                            HStack {
                                Button("Save", action: saveGame)
                                    .foregroundColor(.white)
                                    .padding(.vertical)
                                    .frame(maxWidth: .infinity)
                                    .background(winner == nil ? Color.green : Color.gray)
                                    .cornerRadius(10)
                                    .disabled(winner != nil)
                                Button("Grid", action: changeStateToGrid)
                                    .foregroundColor(.white)
                                    .padding(.vertical)
                                    .frame(maxWidth: .infinity)
                                    .background(winner == nil && gameState == "add" && prevState != "grid" && turnAmount >= 4 ? Color.blue : Color.gray)
                                    .cornerRadius(10)
                                    .disabled(winner != nil || gameState == "move" || prevState == "grid" || turnAmount < 4)
                                NavigationLink(destination: SavedGamesView().modelContainer(for: Game.self)) {
                                    Text("Load")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(winner == nil ? Color.green : Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .simultaneousGesture(TapGesture().onEnded {
                                    saveCurrentContent()
                                })
                                .navigationBarTitle("Home", displayMode: .inline)
                                .disabled(winner != nil)
                            }
                            .padding()
                            
                            
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
                        VStack(spacing: 5) {
                            Text("Player \(currentPlayer.rawValue.uppercased())'s turn")
                                .font(.title2)
                                .foregroundColor(currentPlayer == .x ? .red : .blue)
                            
                            ForEach(0..<5) { row in
                                HStack(spacing: 5) {
                                    ForEach(0..<5) { column in
                                        Button(
                                            action: {
                                                chooseTurnType(row, column)
                                            },
                                            label: {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .foregroundColor(
                                                            currentColor(row, column)
                                                        )
                                                        .frame(width: 45, height: 45)
                                                        .shadow(radius: 5)
                                                    Text(board[row][column]?.rawValue ?? " ")
                                                        .font(.title2)
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
                        }
                    }
                }
                .padding()
                .onAppear {
                    loadSettings()
                }
            } else {
                VStack(spacing: 10) {
                    Text("Tic-Tac-Two")
                        .font(.largeTitle)
                        .padding(.vertical)
                    Text("X buttons: \(xButtons)")
                    Text("O buttons: \(oButtons)")
                    
                    Spacer()
                    
                    Text("Player \(currentPlayer.rawValue.uppercased())'s turn")
                        .font(.title2)
                        .foregroundColor(currentPlayer == .x ? .red : .blue)
                    
                    ForEach(0..<5) { row in
                        HStack(spacing: 10) {
                            ForEach(0..<5) { column in
                                Button(
                                    action: {
                                        chooseTurnType(row, column)
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
                        Button("Save", action: saveGame)
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .background(winner == nil ? Color.green : Color.gray)
                            .cornerRadius(10)
                            .disabled(winner != nil)
                        Button("Grid", action: changeStateToGrid)
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .background(winner == nil && gameState == "add" && prevState != "grid" && turnAmount >= 4 ? Color.blue : Color.gray)
                            .cornerRadius(10)
                            .disabled(winner != nil || gameState == "move" || prevState == "grid" || turnAmount < 4)
                        NavigationLink(destination: SavedGamesView().modelContainer(for: Game.self)) {
                            Text("Load")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(winner == nil ? Color.green : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            saveCurrentContent()
                        })
                        .navigationBarTitle("Home", displayMode: .inline)
                        .disabled(winner != nil)
                    }
                    .padding()
                    
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
                    
                    Button("Reset Game", action: resetGame)
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                .onAppear {
                    loadSettings()
                }
            }
        }
    }
    
    private func saveCurrentContent() {
        prevState = "load"
        let currentPlayerString = currentPlayer.rawValue
        let stringBoard: [[String]] = board.map { row in
            row.map { player in
                player?.rawValue ?? " "
            }
        }
        let intGrid: [[Int]] = grid.map { tuple in
            [tuple.0, tuple.1]
        }
        UserDefaults.standard.set(currentPlayerString, forKey: "loadCurrentPlayer")
        UserDefaults.standard.set(stringBoard, forKey: "loadBoard")
        UserDefaults.standard.set(intGrid, forKey: "loadGrid")
        UserDefaults.standard.set(prevState, forKey: "loadPrevState")
        UserDefaults.standard.set(xButtons, forKey: "loadXButtons")
        UserDefaults.standard.set(oButtons, forKey: "loadOButtons")
        UserDefaults.standard.set(turnAmount, forKey: "loadTurnAmount")
        UserDefaults.standard.set(gridCenter.0, forKey: "loadGridCenterX")
        UserDefaults.standard.set(gridCenter.1, forKey: "loadGridCenterY")
    }
    
    private func chooseTurnType(_ row: Int, _ column: Int) {
        if (gameState == "add" && board[row][column] == currentPlayer && turnAmount >= 4) {
            prevState = gameState
            gameState = "move"
            activeButton = (row, column)
        } else if (gameState == "move" && turnAmount >= 4) {
            prevState = gameState
            moveButton(row, column)
            turnAmount += 1
        } else if (gameState == "add") {
            if ((currentPlayer == .x && xButtons > 0) || (currentPlayer == .o && oButtons > 0)) {
                if board[row][column] == nil {
                    prevState = gameState
                    board[row][column] = currentPlayer
                    if (currentPlayer == .x) {
                        xButtons -= 1
                    } else {
                        oButtons -= 1
                    }
                    currentPlayer =
                    currentPlayer == .x ? .o : .x
                    checkForWinner()
                    turnAmount += 1
                    saveGameState()
                }
            }
        } else if (gameState == "grid" && turnAmount >= 4) {
            prevState = gameState
            changeGridLocation(row, column)
            turnAmount += 1
        }
    }
    
    private func saveGameState() {
        UserDefaults.standard.set(xButtons, forKey: "xButtons")
        UserDefaults.standard.set(oButtons, forKey: "oButtons")
    }
    
    private func saveGame() {
        let date = Date()
        let currentPlayerString = currentPlayer.rawValue
        let stringBoard: [[String]] = board.map { row in
            row.map { player in
                player?.rawValue ?? " "
            }
        }
        let intGrid: [[Int]] = grid.map { tuple in
            [tuple.0, tuple.1]
        }
        let newSavedGame = Game(date: date, currentPlayer: currentPlayerString, board: stringBoard, grid: intGrid, prevState: prevState, xButtons: xButtons, oButtons: oButtons, turnAmount: turnAmount, gridCenterX: gridCenter.0, gridCenterY: gridCenter.1)
        do {
            modelContext.insert(newSavedGame)
            try modelContext.save()
            print("Saved successfully")
        } catch {
            print("Error saving the game: \(error)")
        }
    }
    
    private func loadSettings() {
        if (prevState == "load") {
            if let loadCurrentPlayer = UserDefaults.standard.value(forKey: "loadCurrentPlayer") as? String {
                if (loadCurrentPlayer == "X") {
                    currentPlayer = .x
                } else {
                    currentPlayer = .o
                }
            }
            if let loadPrevState = UserDefaults.standard.value(forKey: "loadPrevState") as? String {
                prevState = loadPrevState
            }
            if let loadXButtons = UserDefaults.standard.value(forKey: "loadXButtons") as? Int {
                xButtons = loadXButtons
            }
            if let loadOButtons = UserDefaults.standard.value(forKey: "loadOButtons") as? Int {
                oButtons = loadOButtons
            }
            if let loadBoard = UserDefaults.standard.value(forKey: "loadBoard") as? [[String]] {
                board = loadBoard.map { row in
                    row.map { value in
                        Player(rawValue: value)
                    }
                }
            }
            if let loadGrid = UserDefaults.standard.value(forKey: "loadGrid") as? [[Int]] {
                for i in 0..<grid.count {
                    grid[i].0 = loadGrid[i][0]
                    grid[i].1 = loadGrid[i][1]
                }
            }
            if let loadTurnAmount = UserDefaults.standard.value(forKey: "loadTurnAmount") as? Int {
                turnAmount = loadTurnAmount
            }
            if let loadGridCenterX = UserDefaults.standard.value(forKey: "loadGridCenterX") as? Int {
                gridCenter.0 = loadGridCenterX
            }
            if let loadGridCenterY = UserDefaults.standard.value(forKey: "loadGridCenterY") as? Int {
                gridCenter.1 = loadGridCenterY
            }
        } else if (prevState == "begin") {
            if let savedValue = UserDefaults.standard.value(forKey: settingsKey) as? Int {
                xButtons = savedValue
                oButtons = savedValue
            }
        } else {
            if let savedXButtons = UserDefaults.standard.value(forKey: "xButtons") as? Int {
                xButtons = savedXButtons
            }
            if let savedOButtons = UserDefaults.standard.value(forKey: "oButtons") as? Int {
                oButtons = savedOButtons
            }
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
    
    func changeStateToGrid() {
        if (gameState == "add") {
            gameState = "grid"
        } else {
            gameState = "add"
        }
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
                if (winner?.rawValue == "X") {
                    let savedXWins2Player = UserDefaults.standard.value(forKey: "xWins2Player") as? Int ?? 0
                    UserDefaults.standard.set(savedXWins2Player + 1, forKey: "xWins2Player")
                } else {
                    let savedOWins2Player = UserDefaults.standard.value(forKey: "oWins2Player") as? Int ?? 0
                    UserDefaults.standard.set(savedOWins2Player + 1, forKey: "oWins2Player")
                }
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
                if (winner?.rawValue == "X") {
                    let savedXWins2Player = UserDefaults.standard.value(forKey: "xWins2Player") as? Int ?? 0
                    UserDefaults.standard.set(savedXWins2Player + 1, forKey: "xWins2Player")
                } else {
                    let savedOWins2Player = UserDefaults.standard.value(forKey: "oWins2Player") as? Int ?? 0
                    UserDefaults.standard.set(savedOWins2Player + 1, forKey: "oWins2Player")
                }
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
            if (winner?.rawValue == "X") {
                let savedXWins2Player = UserDefaults.standard.value(forKey: "xWins2Player") as? Int ?? 0
                UserDefaults.standard.set(savedXWins2Player + 1, forKey: "xWins2Player")
            } else {
                let savedOWins2Player = UserDefaults.standard.value(forKey: "oWins2Player") as? Int ?? 0
                UserDefaults.standard.set(savedOWins2Player + 1, forKey: "oWins2Player")
            }
            return
        }
        //diag2
        if let player = board[grid[2].0][grid[2].1],
           player == board[grid[4].0][grid[4].1],
           player == board[grid[6].0][grid[6].1]
        {
            winner = player
            winningCells = Set([[grid[2].0, grid[2].1], [grid[4].0, grid[4].1], [grid[6].0, grid[6].1]])
            if (winner?.rawValue == "X") {
                let savedXWins2Player = UserDefaults.standard.value(forKey: "xWins2Player") as? Int ?? 0
                UserDefaults.standard.set(savedXWins2Player + 1, forKey: "xWins2Player")
            } else {
                let savedOWins2Player = UserDefaults.standard.value(forKey: "oWins2Player") as? Int ?? 0
                UserDefaults.standard.set(savedOWins2Player + 1, forKey: "oWins2Player")
            }
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
        prevState = "begin"
        turnAmount = 0
        if let savedValue = UserDefaults.standard.value(forKey: settingsKey) as? Int {
            xButtons = savedValue
            oButtons = savedValue
        }
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
}

#Preview() {
    GameBoardView().modelContainer(for: Game.self)
}
