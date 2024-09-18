//
//  MoviewQuizPresenter.swift
//  MovieQuiz
//
//  Created by Ilia Liasin on 12/09/2024.
//

import Foundation
import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func enableButtonToggle()
    func show(quiz step: QuizStepViewModel)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showAlert(model: AlertModel)
    func showAnswerResult(color: CGColor)
}

protocol MoviewQuizPresenterProtocol {
    func loadMovies()
    func restartQuiz()
    func handleAnswer(isCorrect: Bool)
}

final class MoviewQuizPresenter {
    
    //MARK: - Properties
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var currentNumberString: String {
        "\(currentQuestionIndex + 1)/\(questionsAmount)"
    }
    
    private weak var view: MovieQuizViewControllerProtocol?
    
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    
    //MARK: - Lifecycle
    init(viewController: MovieQuizViewControllerProtocol) {
        self.view = viewController
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory?.requestNextQuestion()
        statisticService = StatisticService()
    }
    
    //MARK: - Private functions
    private func showLoadingIndicator() {
        DispatchQueue.main.async {
            self.view?.showLoadingIndicator()
        }
    }
    
    private func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.view?.hideLoadingIndicator()
        }
    }
    
    private func requestNextQuestion() {
        questionFactory?.requestNextQuestion()
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            if isCorrect {
                self.correctAnswers += 1
                self.view?.showAnswerResult(color: UIColor.ypGreen.cgColor)
            } else {
                self.view?.showAnswerResult(color: UIColor.ypRed.cgColor)
            }
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            
            statisticService?.store(correct: correctAnswers, total: 1)
            
            let bestGameDate = statisticService?.bestGame.date.dateTimeString ?? ""
            let accuracy = statisticService?.totalAccuracy ?? 0.0
            let bestGameResult = "\(statisticService?.bestGame.correct ?? 0)/10"
            let message = """
                            Ваш результат: \(correctAnswers)/\(questionsAmount)
                            Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)
                            Рекорд: \(bestGameResult) (\(bestGameDate))
                            Средняя точность: \(String(format: "%.2f", accuracy))%
                            """
            
            showAlert(model: QuizResultsViewModel(title: "Этот раунд окончен!",
                                                  text: message,
                                                  buttonText: "Сыграть еще раз"))
        } else {
            currentQuestionIndex += 1
            requestNextQuestion()
        }
    }
    
    private func showAlert(model: QuizResultsViewModel) {
        let alertModel = AlertModel(title: model.title,
                                    message: model.text,
                                    buttonText: model.buttonText) { [weak self] in
            self?.restartQuiz()
        }
        
        view?.showAlert(model: alertModel)
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.requestNextQuestion()
        }
        
        DispatchQueue.main.async {
            self.view?.showAlert(model: alertModel)
        }
    }
    
}

//MARK: - Extensions
extension MoviewQuizPresenter: MoviewQuizPresenterProtocol {
    
    func loadMovies() {
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    func handleAnswer(isCorrect: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let currentQuestion = currentQuestion else { return }
            
            self.view?.enableButtonToggle()
            self.showAnswerResult(isCorrect: currentQuestion.correctAnswer == isCorrect)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showLoadingIndicator()
            self?.showNextQuestionOrResults()
            self?.view?.enableButtonToggle()
        }
    }
    
    func restartQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        requestNextQuestion()
    }
    
}

//MARK: - Delegates
extension MoviewQuizPresenter: QuestionFactoryDelegate {
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        hideLoadingIndicator()
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view?.show(quiz: viewModel)
        }
    }
}


