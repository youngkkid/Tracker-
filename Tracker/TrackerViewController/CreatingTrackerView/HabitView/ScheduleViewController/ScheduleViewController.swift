import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelect(days: [DayOfWeek])
}

final class ScheduleViewController: UIViewController {
    
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 16
        static let tableViewCornerRadius: CGFloat = 16
        static let doneButtonFontSize: CGFloat = 16
        static let doneButtonCornerRadius: CGFloat = 16
        static let firstCellCornerRadius: CGFloat = 16
        static let lastCellCornerRadius: CGFloat = 16
    }
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    private var selectedDays: [DayOfWeek] = []
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ScheduleCell.self,
                           forCellReuseIdentifier: ScheduleCell.scheduleCellIdentifier)
        tableView.bounces = false
        tableView.layer.cornerRadius = UIConstants.tableViewCornerRadius
        tableView.layer.masksToBounds = true
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = .systemFont(ofSize: UIConstants.doneButtonFontSize,
                                              weight: .regular)
        button.setTitle("Готово", for: .normal)
        button.layer.cornerRadius = UIConstants.doneButtonCornerRadius
        button.layer.masksToBounds = true
        button.addTarget(self,
                         action: #selector(backToHabitViewController),
                         for: .touchUpInside)
        return button
    }()
    
    init(delegate: ScheduleViewControllerDelegate? = nil, selectedDays: [DayOfWeek]) {
        self.delegate = delegate
        self.selectedDays = selectedDays
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    @objc private func backToHabitViewController() {
        delegate?.didSelect(days: selectedDays)
        dismiss(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DayOfWeek.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.scheduleCellIdentifier, for: indexPath) as? ScheduleCell else {
            return UITableViewCell()
        }
        cell.layer.cornerRadius = UIConstants.firstCellCornerRadius
        cell.layer.masksToBounds = true
        
        if indexPath.row == 0 {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == DayOfWeek.allCases.count - 1 {
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.layer.maskedCorners = []
        }
        
        cell.delegate = self
        let dayOfWeek = DayOfWeek.allCases[indexPath.row]
        cell.dayOfWeek = dayOfWeek
        cell.isSwitchOn = selectedDays.contains(dayOfWeek)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return cell
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension ScheduleViewController: ScheduleViewCellDelegate {
    func switchStateChanged(isON isOn: Bool, day: DayOfWeek?) {
        guard let day = day else {return}
        if isOn {
            selectedDays.append(day)
        } else {
            if let index = selectedDays.firstIndex(of: day) {
                selectedDays.remove(at: index)
            }
        }
    }
}

extension ScheduleViewController {
    private func initialize() {
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .systemBackground
        
        [titleLabel,
         tableView,
         doneButton].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}
