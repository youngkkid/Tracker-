
import UIKit

final class HabitOrEventCategoryCell: UITableViewCell {
    
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 17
    }
    
    static let habitCategoryCellIdentifier = "CategoryCell"
    
    private var titleLabelTopConstraint: NSLayoutConstraint?
    private var titleLabelCenterYConstraint: NSLayoutConstraint?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.textColor = .black
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        return label
    }()
    
    private lazy var categoriesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeCategoriesLabel(categories: String) {
        categoriesLabel.text = categories
        updateTitleLabelConstraints()
    }
    
    private func updateTitleLabelConstraints() {
        if let text = categoriesLabel.text, !text.isEmpty {
            titleLabelCenterYConstraint?.isActive = false
            titleLabelTopConstraint?.isActive = true
        } else {
            titleLabelTopConstraint?.isActive = false
            titleLabelCenterYConstraint?.isActive = true
            
        }
        setNeedsLayout()
    }
}

extension HabitOrEventCategoryCell {
    private func initialize() {
        accessoryType = .disclosureIndicator
        selectionStyle = .none
        
        backgroundColor = .ypLightGray
        [titleLabel,
         categoriesLabel].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        titleLabelTopConstraint = titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15)
        titleLabelCenterYConstraint = titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            categoriesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            categoriesLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
        updateTitleLabelConstraints()
    }
}
