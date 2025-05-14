
import UIKit

final class CategoryCell: UITableViewCell {
    
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 17
    }
    
    static let categoryCellIdentifier = "categoryCell"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        return label
    }()
    
    private lazy var checkMarkImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCheckMark() {
        checkMarkImageView.image = .categoryCheckmark
    }
    
    func removeCheckMark() {
        checkMarkImageView.image = nil
    }
}

extension CategoryCell {
    private func initialize() {
        accessoryType = .none
        backgroundColor = .ypLightGray
        
        [titleLabel,
         checkMarkImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 75),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            checkMarkImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -21),
            checkMarkImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
