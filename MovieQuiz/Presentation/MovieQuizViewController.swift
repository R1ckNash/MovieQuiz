import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func enableButtonToggle()
    func show(quiz step: QuizStepViewModel)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showAlert(model: AlertModel)
    func showAnswerResult(color: CGColor)
}

final class MovieQuizViewController: UIViewController {
    
    //MARK: - Properties
    private var alertPresenter: AlertPresenterProtocol!
    private var moviewQuizPresenter: MovieQuizPresenterProtocol!
    
    //MARK: - IBOutlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moviewQuizPresenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(viewController: self)
        
        setupStyle()
        setupBehavior()
        
        moviewQuizPresenter.viewDidLoad()
    }
    
    //MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        moviewQuizPresenter.didTapAnswerButton(isCorrect: true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        moviewQuizPresenter.didTapAnswerButton(isCorrect: false)
    }
    
    //MARK: - Private functions
    private func setupStyle() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        
        activityIndicator.style = .large
    }
    
    private func setupBehavior() {
        activityIndicator.hidesWhenStopped = true
    }
    
}

//MARK: - Extensions
extension MovieQuizViewController: MovieQuizViewControllerProtocol {
    
    func showAnswerResult(color: CGColor) {
        imageView.layer.borderColor = color
    }
    
    func enableButtonToggle() {
        noButton.isEnabled.toggle()
        yesButton.isEnabled.toggle()
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.borderColor = UIColor.clear.cgColor
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showAlert(model: AlertModel) {
        alertPresenter.showAlert(model: model)
    }
}

