import UIKit

class WrongNoteCell: UITableViewCell {
    
    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var koreanLabel: UILabel!
    @IBOutlet weak var unnoteButton: UIButton!
    
    var onUnnote: (() -> Void)?
    
    @IBAction func unnoteButtonTapped(_ sender: UIButton) {
        onUnnote?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        preservesSuperviewLayoutMargins = false

        englishLabel.font = UIFont.boldSystemFont(ofSize: 24)
        koreanLabel.font = UIFont.boldSystemFont(ofSize: 24)
    }

    func configure(english: String, korean: String, isHidden: Bool, onUnnote: @escaping () -> Void) {
        englishLabel.text = english
        koreanLabel.text = isHidden ? "👀" : korean
        self.onUnnote = onUnnote

        unnoteButton.setTitle("❎", for: .normal)
        unnoteButton.setTitleColor(.black, for: .normal)
        unnoteButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)

        let highlightColor = isHidden ? UIColor.systemOrange : UIColor.systemTeal
        contentView.layer.borderColor = highlightColor.cgColor
    }

}
