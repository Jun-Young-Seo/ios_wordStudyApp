import UIKit
import FirebaseFirestore

class WordListViewController: UIViewController {

    @IBOutlet weak var elementaryCardView: UIView!
    @IBOutlet weak var csatCardView: UIView!
    @IBOutlet weak var toeicCardView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let elementaryTap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        elementaryCardView.addGestureRecognizer(elementaryTap)
        elementaryCardView.tag = 1
        
        let csatTap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        csatCardView.addGestureRecognizer(csatTap)
        csatCardView.tag = 2
        
        let toeicTap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        toeicCardView.addGestureRecognizer(toeicTap)
        toeicCardView.tag = 3
    }

    // 카드 탭 이벤트 처리
    @objc func cardTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view else { return }

        var title: String = ""
        var categoryKey: String = ""

        switch tappedView.tag {
        case 1:
            title = "초등 영단어"
            categoryKey = "elementary"
        case 2:
            title = "수능 영단어"
            categoryKey = "csat"
        case 3:
            title = "토익 영단어"
            categoryKey = "toeic"
        default:
            return
        }

        let db = Firestore.firestore()
        db.collection("words").whereField("category", isEqualTo: categoryKey).getDocuments { snapshot, error in
            if let error = error {
                return
            }

            guard let documents = snapshot?.documents else {
                return
            }

            let words: [(english: String, korean: String, isHidden: Bool, isNoted: Bool)] = documents.compactMap { doc in
                let data = doc.data()
                guard let english = data["english"] as? String,
                      let korean = data["korean"] as? String else { return nil }
                
                let isNoted = data["is_noted"] as? Bool ?? false
                
                return (english: english, korean: korean, isHidden: true, isNoted: isNoted)
            }


            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let studyVC = storyboard.instantiateViewController(withIdentifier: "StudyVC") as? StudyViewController {
                    studyVC.pageTitle = title
                    studyVC.words = words
                    self.navigationController?.pushViewController(studyVC, animated: true)
                }
            }
        }
    }

}
