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
    
    enum BestGameKeys: String {
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
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
            let correct = userDefaults.integer(forKey: BestGameKeys.bestGameCorrect.rawValue)
            let total = userDefaults.integer(forKey: BestGameKeys.bestGameTotal.rawValue)
            let date = userDefaults.double(forKey: BestGameKeys.bestGameDate.rawValue)
            
            if correct == 0 && total == 0 && date == 0 {
                return GameResult(correct: 0, total: 0, date: Date())
            }
            
            return GameResult(correct: correct, total: total, date: Date(timeIntervalSince1970: date))
        }
        set {
            userDefaults.set(newValue.correct, forKey: BestGameKeys.bestGameCorrect.rawValue)
            userDefaults.set(newValue.total, forKey: BestGameKeys.bestGameTotal.rawValue)
            userDefaults.set(newValue.date.timeIntervalSince1970, forKey: BestGameKeys.bestGameDate.rawValue)
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
