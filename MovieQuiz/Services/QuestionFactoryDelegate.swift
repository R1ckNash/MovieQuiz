//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Ilia Liasin on 21/08/2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
