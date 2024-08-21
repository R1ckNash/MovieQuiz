//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Ilia Liasin on 21/08/2024.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
    }
    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let gameResult = try? JSONDecoder().decode(GameResult.self, from: data) else {
                return GameResult(correct: 0, total: 0, date: Date())
            }
            return gameResult
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                userDefaults.set(data, forKey: Keys.bestGame.rawValue)
            }
        }
    }
    
    var totalAccuracy: Double {
        let correctAnswers = correctAnswers
        let totalQuestions = gamesCount * 10
        
        guard totalQuestions > 0 else {
            return 0.0
        }
        
        return (Double(correctAnswers) / Double(totalQuestions)) * 100
    }
    
    private var correctAnswers: Int {
            get {
                return userDefaults.integer(forKey: Keys.correct.rawValue)
            }
            set {
                userDefaults.set(newValue, forKey: Keys.correct.rawValue)
            }
        }
    
    func store(correct count: Int, total amount: Int) {
        correctAnswers += count
        gamesCount += amount
        
        let currentGameResult = GameResult(correct: count, total: amount, date: Date())
        if currentGameResult > bestGame {
            bestGame = currentGameResult
        }
    }
}
