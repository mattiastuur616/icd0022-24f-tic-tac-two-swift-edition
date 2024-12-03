//
//  Game.swift
//  tic_tac_2
//
//  Created by Mattias Tüür on 02.12.2024.
//

import Foundation
import SwiftData

@Model
final public class Game : ObservableObject, Identifiable  {
    
    var date: Date
    var currentPlayer: String
    var board: [[String]]
    var grid: [[Int]]
    var prevState: String
    var xButtons: Int
    var oButtons: Int
    var turnAmount: Int
    var gridCenterX: Int
    var gridCenterY: Int
    
    init(date: Date, currentPlayer: String, board: [[String]], grid: [[Int]], prevState: String,
         xButtons: Int, oButtons: Int, turnAmount: Int, gridCenterX: Int, gridCenterY: Int) {
        self.date = date
        self.currentPlayer = currentPlayer
        self.board = board
        self.grid = grid
        self.prevState = prevState
        self.xButtons = xButtons
        self.oButtons = oButtons
        self.turnAmount = turnAmount
        self.gridCenterX = gridCenterX
        self.gridCenterY = gridCenterY
    }
}
