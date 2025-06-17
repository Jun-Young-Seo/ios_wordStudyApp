import UIKit
import FirebaseFirestore

class QuizViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerButton1: UIButton!
    @IBOutlet weak var answerButton2: UIButton!
    @IBOutlet weak var answerButton3: UIButton!
    @IBOutlet weak var answerButton4: UIButton!
    
    let db = Firestore.firestore()
    var category: String = ""
    
    var wordList: [(english: String, korean: String, isHidden: Bool)] = []
    private var quizList: [(english: String, korean: String)] = []
    private var currentIndex = 0
    private var correctCount = 0
    private var currentOptions: [String] = []
    
    private var timer: Timer?
    private var timeLeft: Float = 1.0
    private var hasAnswered = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        answerButton1.tag = 0
        answerButton2.tag = 1
        answerButton3.tag = 2
        answerButton4.tag = 3
        
        quizList = wordList
            .filter { !$0.isHidden }
            .map { ($0.english, $0.korean) }
            .shuffled()
        currentIndex = 0
        correctCount = 0
        setupQuestion()
    }
    
    private func setupQuestion() {
        hasAnswered = false
        
        guard currentIndex < quizList.count else {
            showQuizResult()
            return
        }
        
        let (eng, kor) = quizList[currentIndex]
        questionLabel.text = eng
        countLabel.text = "\(currentIndex+1) / \(quizList.count)"
        
        let allKorean = wordList.map { $0.korean }
        let wrongs = Array(Set(allKorean).subtracting([kor])).shuffled().prefix(3)
        currentOptions = Array(wrongs) + [kor]
        currentOptions.shuffle()
        
        let buttons = [answerButton1, answerButton2, answerButton3, answerButton4]
        for (i, btn) in buttons.enumerated() {
            guard let btn = btn else { continue }
            btn.setTitle(currentOptions[i], for: .normal)
            btn.isEnabled = true
            btn.alpha = 1.0
            btn.backgroundColor = .white
        }
        
        timeLeft = 1.0
        progressBar.progress = timeLeft
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self, !self.hasAnswered else { return }
            self.timeLeft -= 0.01
            self.progressBar.progress = self.timeLeft
            if self.timeLeft <= 0 {
                self.hasAnswered = true
                self.timer?.invalidate()
                self.handleAnswer(selectedIndex: nil)
            }
        }
    }
    
    @IBAction private func answerSelected(_ sender: UIButton) {
        guard !hasAnswered else { return }
        hasAnswered = true
        timer?.invalidate()
        
        let idx = sender.tag
        handleAnswer(selectedIndex: idx)
    }
    
    private func handleAnswer(selectedIndex: Int?) {
        let correctIndex = currentOptions.firstIndex(of: quizList[currentIndex].1)!
        let buttons = [answerButton1, answerButton2, answerButton3, answerButton4]
        
        buttons.forEach { $0?.isEnabled = false }
        
        if let sel = selectedIndex {
            if sel == correctIndex {
                // 정답
                correctCount += 1
                buttons[sel]?.setTitle("✅ " + currentOptions[sel], for: .normal)
                buttons[sel]?.backgroundColor = .systemGreen
            } else {
                // 오답
                buttons[sel]?.setTitle("❌ " + currentOptions[sel], for: .normal)
                buttons[sel]?.backgroundColor = .systemRed
                // 정답 표시
                buttons[correctIndex]?.setTitle("✅ " + currentOptions[correctIndex], for: .normal)
                buttons[correctIndex]?.backgroundColor = .systemGreen
            }
        } else {
            // 시간 초과
            buttons[correctIndex]?.setTitle("✅ " + currentOptions[correctIndex], for: .normal)
            buttons[correctIndex]?.backgroundColor = .systemGreen
        }
        
        // 나머지 보기 흐리게
        for i in 0..<buttons.count {
            if i != selectedIndex && i != correctIndex {
                buttons[i]?.alpha = 0.3
            }
        }
        
        // 다음 문제로 넘어가기
        let delay: TimeInterval = (selectedIndex == correctIndex) ? 0.3 : 0.6
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.currentIndex += 1
            self.setupQuestion()
        }
    }
    
    private func showQuizResult() {
        let alert = UIAlertController(
            title: "시험 종료",
            message: "모든 문제를 풀었습니다!\n정답 수: \(correctCount) / \(quizList.count)",
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "메인으로 돌아가기", style: .default) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
