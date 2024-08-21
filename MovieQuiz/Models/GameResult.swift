//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Ilia Liasin on 21/08/2024.
//

import Foundation

struct GameResult: Comparable, Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    static func < (lhs: GameResult, rhs: GameResult) -> Bool {
        lhs.correct < rhs.correct
    }
}
