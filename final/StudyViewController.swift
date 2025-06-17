import UIKit
import FirebaseFirestore

class StudyViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var pageTitle: String = "단어 공부"
    var words: [(english: String, korean: String, isHidden: Bool, isNoted: Bool)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = pageTitle
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        tableView.separatorStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension StudyViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    func tableView(_ tv: UITableView, cellForRowAt ip: IndexPath) -> UITableViewCell {
        guard let cell = tv.dequeueReusableCell(withIdentifier: "WordCell", for: ip) as? WordCell else {
            fatalError("WordCell 로드 실패")
        }
        
        let w = words[ip.row]
        cell.configure(
            english: w.english,
            korean: w.korean,
            isHidden: w.isHidden,
            isNoted: w.isNoted,
            onNoteToggle: { [weak self] in
                guard let self = self else { return }
                self.words[ip.row].isNoted.toggle()
                self.updateNoteInFirebase(word: self.words[ip.row])
            }
        )
        
        return cell
    }

    
    // 셀 탭 시 hidden 토글, 해당 행만 리로드
    func tableView(_ tv: UITableView, didSelectRowAt ip: IndexPath) {
        words[ip.row].isHidden.toggle()
        tv.reloadRows(at: [ip], with: .automatic)
    }
    
    func updateNoteInFirebase(word: (english: String, korean: String, isHidden: Bool, isNoted: Bool)) {
        let db = Firestore.firestore()
        
        let docId = "\(word.english)_\(word.korean)"
        
        db.collection("words").document(docId).updateData([
            "is_noted": word.isNoted
        ]) { error in
            if let error = error {
                return
            }
        }
    }

}
