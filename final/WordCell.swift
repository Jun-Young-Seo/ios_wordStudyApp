import UIKit

class WordCell: UITableViewCell {
    
    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var koreanLabel: UILabel!
    @IBOutlet weak var noteButton: UIButton!
    
    private var noteToggleAction: (() -> Void)?
    private var isNotedInternal: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.layer.masksToBounds = true
        
        contentView.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        preservesSuperviewLayoutMargins = false
        
        englishLabel.font = UIFont.boldSystemFont(ofSize: 24)
        englishLabel.numberOfLines = 1
        
        koreanLabel.font = UIFont.boldSystemFont(ofSize: 24)
        koreanLabel.numberOfLines = 0
        
        noteButton.backgroundColor = .clear
        noteButton.setTitleColor(.black, for: .normal)
        noteButton.titleLabel?.font = UIFont.systemFont(ofSize: 26)
    }
    
    func configure(
        english: String,
        korean: String,
        isHidden: Bool,
        isNoted: Bool,
        onNoteToggle: @escaping () -> Void
    ) {
        englishLabel.text = english
        koreanLabel.text = isHidden ? "👀" : korean
        
        self.noteToggleAction = onNoteToggle
        self.isNotedInternal = isNoted
        
        updateNoteButtonEmoji()
        
        let borderColor: UIColor = isHidden ? .systemOrange : .systemTeal
        contentView.layer.borderColor = borderColor.cgColor
    }

    @IBAction func didTapNoteButton(_ sender: UIButton) {
        noteToggleAction?()
        isNotedInternal.toggle()
        updateNoteButtonEmoji()
    }

    private func updateNoteButtonEmoji() {
        let emoji = isNotedInternal ? "📘" : "➕"
        noteButton.setTitle(emoji, for: .normal)
    }
}
