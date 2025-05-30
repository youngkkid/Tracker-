import UIKit

final class CreatingTrackerViewController: UIViewController {
    
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 16
        static let createHabitButtonTitleLabelFontSize: CGFloat = 16
        static let createIrregularEventButtonTitleLabelFontSize: CGFloat = 16
        static let createHabitButtonCornerRadius: CGFloat = 16
        static let createIrregularEventButtonCornerRadius: CGFloat = 16
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        return label
    }()
    
    private lazy var createHabitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = .systemFont(ofSize: UIConstants.createHabitButtonTitleLabelFontSize,
                                              weight: .regular)
        button.setTitle("Привычка", for: .normal)
        button.layer.cornerRadius = UIConstants.createHabitButtonCornerRadius
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(tapCreateHabitButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var createIrregularEventButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = .systemFont(ofSize: UIConstants.createIrregularEventButtonTitleLabelFontSize,
                                              weight: .regular)
        button.setTitle("Нерегулярное событие", for: .normal)
        button.layer.cornerRadius = UIConstants.createIrregularEventButtonCornerRadius
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(tapCreateIrregularEventButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    @objc private func tapCreateHabitButton() {
        let habitViewController = HabitOrEventViewController()
        habitViewController.isHabit = true
        present(habitViewController, animated: true)
    }
    
    @objc private func tapCreateIrregularEventButton(){
        let habitViewController = HabitOrEventViewController()
        habitViewController.isHabit = false
        present(habitViewController, animated: true)
    }
}

extension CreatingTrackerViewController {
    private func initialize() {
        view.backgroundColor = .systemBackground
        [titleLabel,
         createHabitButton,
         createIrregularEventButton].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            createHabitButton.heightAnchor.constraint(equalToConstant: 60),
            createHabitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createHabitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -323),
            createHabitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            createIrregularEventButton.heightAnchor.constraint(equalToConstant: 60),
            createIrregularEventButton.topAnchor.constraint(equalTo: createHabitButton.bottomAnchor, constant: 16),
            createIrregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createIrregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}
