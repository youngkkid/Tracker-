import UIKit

final class EmojisCollectionViewCell: UICollectionViewCell {
    
    private enum UIConstants {
        static let emojiLabelFontSize: CGFloat = 32
        static let emojiLabelCornerRadius: CGFloat = 16
    }
    
    static let emojisCollectionViewCellIdentifier = "EmojisColletcionViewCell"
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UIConstants.emojiLabelFontSize)
        label.layer.cornerRadius = UIConstants.emojiLabelCornerRadius
        label.layer.masksToBounds = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateEmojiLabel(emoji: String) {
        emojiLabel.text = emoji
    }
    
    func updateEmojiBackgroundColor(color: UIColor) {
        emojiLabel.backgroundColor = color
    }
    
    
}

extension EmojisCollectionViewCell {
    private func initialize() {
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.heightAnchor.constraint(equalToConstant: frame.width),
                    emojiLabel.widthAnchor.constraint(equalToConstant: frame.width),
                    emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                    emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
