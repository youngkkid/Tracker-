import UIKit

protocol ScheduleViewCellDelegate: AnyObject {
    func switchStateChanged(isON: Bool, day: DayOfWeek?)
}

final class ScheduleCell: UITableViewCell {
    
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 17
    }
    
    static let scheduleCellIdentifier = "ScheduleCell"
    
    var dayOfWeek: DayOfWeek? {
        didSet {
            titleLabel.text = dayOfWeek?.russianName
        }
    }
    
    var isSwitchOn: Bool {
        get {
            return switchControl.isOn
        }
        set {
            switchControl.isOn = newValue
        }
    }
    
    weak var delegate: ScheduleViewCellDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        return label
    }()
    
    private lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .ypBlue
        switchControl.addTarget(self,
                                action: #selector(switchDidChanged),
                                for: .valueChanged)
        return switchControl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func switchDidChanged(_ sender: UISwitch) {
        delegate?.switchStateChanged(isON: sender.isOn, day: dayOfWeek)
    }
}

extension ScheduleCell {
    private func initialize() {
        accessoryType = .none
        selectionStyle = .none
        backgroundColor = .ypLightGray
        
        [titleLabel,
         switchControl].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
