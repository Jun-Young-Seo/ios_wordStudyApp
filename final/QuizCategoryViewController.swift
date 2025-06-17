import UIKit
import FirebaseFirestore

class QuizCategoryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "시험 유형 선택"
    }

    @IBAction func elementaryQuizTapped(_ sender: UIButton) {
        goToQuiz(for: "elementary")
    }

    @IBAction func csatQuizTapped(_ sender: UIButton) {
        goToQuiz(for: "csat")
    }

    @IBAction func toeicQuizTapped(_ sender: UIButton) {
        goToQuiz(for: "toeic")
    }

    private func goToQuiz(for categoryName: String) {
        let db = Firestore.firestore()
        db.collection("words").whereField("category", isEqualTo: categoryName).getDocuments { snapshot, error in
            if let error = error {
                return
            }

            guard let docs = snapshot?.documents else { return }

            let words: [(String, String, Bool)] = docs.compactMap { doc in
                let data = doc.data()
                guard let en = data["english"] as? String,
                      let ko = data["korean"] as? String else { return nil }
                return (en, ko, false)
            }

            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let quizVC = storyboard.instantiateViewController(withIdentifier: "QuizVC") as? QuizViewController {
                    quizVC.wordList = words
                    quizVC.category = categoryName
                    self.navigationController?.pushViewController(quizVC, animated: true)
                }
            }
        }
    }
}
