import UIKit

final class OnboardingView: UIView {
    
    var onFinish: (() -> Void)?
    
    private enum UIConstants {
        static let pageLabelFontSize: CGFloat = 32
    }
    
    private lazy var pageImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var pageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .boldSystemFont(ofSize: UIConstants.pageLabelFontSize)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var pageButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPageLabelText(text: String) {
        pageLabel.text = text
    }
    
    func setButton(text: String) {
        pageButton.setTitle(text, for: .normal)
    }
    
    func setImageView(for image: UIImage) {
        pageImageView.image = image
    }
    
    func set(transform: CGAffineTransform) {
        pageLabel.transform = transform
        pageButton.transform = transform
    }
    
    @objc
    private func didTapButton() {
        onFinish?()
    }
}


extension OnboardingView {
    private func initialize() {
        [pageImageView,
         pageLabel,
         pageButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
            
        }
        
        NSLayoutConstraint.activate([
            pageImageView.topAnchor.constraint(equalTo: topAnchor),
            pageImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pageImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            pageImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            pageLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 388),
            pageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            pageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            pageButton.widthAnchor.constraint(equalToConstant: 335),
            pageButton.heightAnchor.constraint(equalToConstant: 60),
            pageButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -50),
            pageButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
