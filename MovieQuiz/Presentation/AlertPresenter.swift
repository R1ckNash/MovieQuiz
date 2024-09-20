//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Ilia Liasin on 21/08/2024.
//

import Foundation
import UIKit

protocol AlertPresenterProtocol {
    func showAlert(model: AlertModel)
}

final class AlertPresenter {
    
    //MARK: - Poperties
    private weak var viewController: UIViewController?
    
    //MARK: - Lifecycle
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
}

//MARK: - Extensions
extension AlertPresenter: AlertPresenterProtocol {
    
    func showAlert(model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        
        alert.view.accessibilityIdentifier = "Game results"
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        
        alert.addAction(action)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.present(alert, animated: true, completion: nil)
        }
    }
    
}
