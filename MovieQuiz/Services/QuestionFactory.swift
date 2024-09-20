//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Ilia Liasin on 20/08/2024.
//

import Foundation

protocol QuestionFactoryProtocol: AnyObject {
    
    var delegate: QuestionFactoryDelegate? { get set }
    func requestNextQuestion()
    func loadData()
}

final class QuestionFactory {
    
    //MARK: - Properties
    weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    
    //MARK: - Lifecycle
    init(moviesLoader: MoviesLoading) {
        self.moviesLoader = moviesLoader
    }
    
    private enum LoadError: Error {
        case loadImageError(String)
    }
}

//MARK: - Extensions
extension QuestionFactory: QuestionFactoryProtocol {
    
    func requestNextQuestion() {
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                let error = LoadError.loadImageError("Failed to load image")
                
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.delegate?.didFailToLoadData(with: error)
                }
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let totalRating = self.movies.compactMap { Float($0.rating) }.reduce(0, +)
            let averageRating = totalRating / Float(self.movies.count)
            
            let adjustment = Float.random(in: -1.0...1.0)
            let threshold = ((averageRating + adjustment) * 10).rounded() / 10
            
            let comparisonIsGreater = Bool.random()
            let text: String
            let correctAnswer: Bool
            
            if comparisonIsGreater {
                text = "Рейтинг этого фильма больше чем \(threshold)?"
                correctAnswer = rating > threshold
            } else {
                text = "Рейтинг этого фильма меньше чем \(threshold)?"
                correctAnswer = rating < threshold
            }
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let movies):
                    self.movies = movies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}
