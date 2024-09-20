//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Ilia Liasin on 19/09/2024.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    
    var shownColor: CGColor?
    
    func enableButtonToggle() {}
    func show(quiz step: MovieQuiz.QuizStepViewModel) {}
    func showLoadingIndicator() {}
    func hideLoadingIndicator() {}
    func showAlert(model: MovieQuiz.AlertModel) {}
    
    func showAnswerResult(color: CGColor) {
        shownColor = color
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = presenter.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
    
    func testHandleAnswerCorrect() {
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        presenter.didReceiveNextQuestion(question: question)
        
        let expectation = XCTestExpectation(description: "Color change expectation")
        
        presenter.didTapAnswerButton(isCorrect: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let expectedColor = UIColor.ypGreen.cgColor
            let shownColor = viewControllerMock.shownColor
            
            XCTAssertEqual(expectedColor, shownColor, "Цвет ответа должен быть зеленым.")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testHandleAnswerNotCorrect() {
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        presenter.didReceiveNextQuestion(question: question)
        
        let expectation = XCTestExpectation(description: "Color change expectation")
        
        presenter.didTapAnswerButton(isCorrect: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let expectedColor = UIColor.ypRed.cgColor
            let shownColor = viewControllerMock.shownColor
            
            XCTAssertEqual(expectedColor, shownColor, "Цвет ответа должен быть красным.")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
}
