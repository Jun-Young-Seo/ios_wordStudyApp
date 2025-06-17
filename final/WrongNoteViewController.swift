import UIKit
import FirebaseFirestore

class WrongNoteViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var words: [(id: String, english: String, korean: String, isHidden: Bool)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "오답노트 📘"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        loadNotedWords()
    }
    
    /// Firestore에서 is_noted == true 인 단어만 로드
    func loadNotedWords() {
        let db = Firestore.firestore()
        
        db.collection("words")
            .whereField("is_noted", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    return
                }
                
                self.words = documents.compactMap { doc in
                    let data = doc.data()
                    guard let english = data["english"] as? String,
                          let korean = data["korean"] as? String else { return nil }
                    return (id: doc.documentID, english: english, korean: korean, isHidden: true)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }
    
    /// Firestore에서 is_noted = false로 업데이트 후 로컬에서도 삭제
    func unnoteWord(at index: Int) {
        let word = words[index]
        let db = Firestore.firestore()
        
        db.collection("words").document(word.id).updateData([
            "is_noted": false
        ]) { error in
            if let error = error {
                return
            }
            
            
            self.words.remove(at: index)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension WrongNoteViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if words.isEmpty {
            tableView.setEmptyMessage("📭 오답노트가 비어 있습니다!")
        } else {
            tableView.restore()
        }
        return words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WrongNoteCell", for: indexPath) as? WrongNoteCell else {
            fatalError("WrongNoteCell 로드 실패")
        }
        
        let word = words[indexPath.row]
        cell.configure(
            english: word.english,
            korean: word.korean,
            isHidden: word.isHidden,
            onUnnote: { [weak self] in
                self?.unnoteWord(at: indexPath.row)
            }
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        words[indexPath.row].isHidden.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .lightGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .none
    }
}
