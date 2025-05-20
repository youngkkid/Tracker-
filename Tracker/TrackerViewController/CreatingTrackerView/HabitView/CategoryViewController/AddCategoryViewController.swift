
import UIKit

final class AddCategoryViewController: UIViewController {
    
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 16
        static let textFieldCornerRadius: CGFloat = 16
        static let createButtonFontSize: CGFloat = 16
        static let createButtonCornerRadius: CGFloat = 16
    }
    
    weak var delegate: AddCategoryViewControllerDelegate?
    private var nameOfCategory: String?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        return label
    }()
    
    private  lazy var textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .ypLightGray
        textField.placeholder = "Введите значение категории"
        
        let leftPaddingView = UIView(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width: 16,
                                                   height: textField.frame.height))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        
        textField.layer.cornerRadius = UIConstants.textFieldCornerRadius
        textField.layer.masksToBounds = true
        return textField
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UIConstants.createButtonFontSize)
        button.backgroundColor = .ypGray
        button.isEnabled = false
        button.layer.cornerRadius = UIConstants.createButtonCornerRadius
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTaP))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTapCreateButton() {
        guard let nameOfCategory = nameOfCategory else {return}
        delegate?.addCategory(nameOfCategory: nameOfCategory)
        dismiss(animated: true)
    }
    
    @objc private func handleTaP() {
        view.endEditing(true)
    }
}

extension AddCategoryViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        nameOfCategory = textField.text
        if let text = textField.text, !text.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddCategoryViewController {
    private func initialize() {
        textField.delegate = self
        view.backgroundColor = .systemBackground
        
        [titleLabel,
         textField,
         createButton].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)}
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}


