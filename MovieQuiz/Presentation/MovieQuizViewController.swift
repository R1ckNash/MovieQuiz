import UIKit

final class MovieQuizViewController: UIViewController {
    
    //MARK: - Properties
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol?
    private var alertPresenter: AlertPresenter!
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var currentNumberString: String {
        "\(currentQuestionIndex + 1)/\(questionsAmount)"
    }
    
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
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory?.requestNextQuestion()
        
        statisticService = StatisticService()
        alertPresenter = AlertPresenter(viewController: self)
        
        setupStyle()
        setupBehavior()
        
        initialLoading()
    }
    
    //MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        handleAnswer(isCorrect: true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        handleAnswer(isCorrect: false)
    }
    
    //MARK: - Private functions
    
    private func initialLoading() {
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
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
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.borderColor = UIColor.clear.cgColor
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func enableButtonToggle() {
        noButton.isEnabled.toggle()
        yesButton.isEnabled.toggle()
    }
    
    private func handleAnswer(isCorrect: Bool) {
        enableButtonToggle()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let currentQuestion = currentQuestion else { return }
            
            self.showAnswerResult(isCorrect: currentQuestion.correctAnswer == isCorrect)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.showLoadingIndicator()
            self.showNextQuestionOrResults()
            
            self.enableButtonToggle()
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
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
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showAlert(model: QuizResultsViewModel) {
        let alertModel = AlertModel(title: model.title,
                                    message: model.text,
                                    buttonText: model.buttonText) { [weak self] in
            guard let self else { return }
            self.restartQuiz()
        }
        
        alertPresenter.showAlert(model: alertModel)
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter.showAlert(model: alertModel)
    }
    
    private func restartQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
}

//MARK: - Delegates
extension MovieQuizViewController: QuestionFactoryDelegate {
    
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
            self.show(quiz: viewModel)
        }
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
