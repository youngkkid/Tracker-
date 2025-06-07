import UIKit

final class HabitOrEventViewController: UIViewController {
    
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 16
        static let cancelButtonFontSize: CGFloat = 16
        static let cancelButtonCornerRadius: CGFloat = 16
        static let createButtonFontSize: CGFloat = 16
        static let createButtonCornerRadius: CGFloat = 16
        static let textFieldCornerRadius: CGFloat = 16
        static let signsLimitLabelFontSize: CGFloat = 17
        static let HabitOrEventCategoryCellCornerRadius: CGFloat = 16
    }
    
    var isHabit = false
    var scheduleCell: ScheduleCell?
    
    private var tableViewTopConstraint: NSLayoutConstraint?
    
    private var selectedDays: [DayOfWeek] = []
    private var selectedCategory: TrackerCategory?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private let dataManager = DataManager.shared
    private let params: GeometricParams = {
        let params = GeometricParams(cellCount: 6,
                                     topInset: 24,
                                     bottomInset: 40,
                                     leftInset: 18,
                                     rightInset: 18,
                                     cellSpacing: 5)
        
        return params
    }()
    
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    private let colors: [UIColor] = [.color1, .color2, .color3, .color4, .color5, .color6, .color7, .color8, .color9, .color10, .color11, .color12, .color13, .color14, .color15, .color16, .color17, .color18]
    
    private lazy var trackerDataProvider: TrackerDataProviderProtocol? = {
        let trackerDataStore = TrackerStore()
        do {
            try trackerDataProvider =  TrackerDataProvider(trackerStore: trackerDataStore, delegate: self)
            return trackerDataProvider
        } catch {
            print("Data is unavailable")
            return nil
        }
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .ypLightGray
        textField.placeholder = "Введите название трекера"
        
        let leftInsetView = UIView(frame: CGRect(x: 0,
                                                 y: 0,
                                                 width: 16,
                                                 height: textField.frame.height))
        textField.leftView = leftInsetView
        textField.leftViewMode = .always
        
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(.xMarkButton, for: .normal)
        clearButton.frame = CGRect(x: 0,
                                   y: 0,
                                   width: 17,
                                   height: 17)
        clearButton.addTarget(self,
                              action: #selector(didTapClearTextFieldButton),
                              for: .touchUpInside)
        
        let rightClearButtonContainer = UIView(frame: CGRect(x: 0,
                                                             y: 0,
                                                             width: clearButton.frame.width + 12,
                                                             height: clearButton.frame.height))
        rightClearButtonContainer.addSubview(clearButton)
        textField.rightView = rightClearButtonContainer
        textField.rightViewMode = .whileEditing
        
        textField.layer.cornerRadius = UIConstants.textFieldCornerRadius
        return textField
    }()
    
    private lazy var signsLimitLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypRed
        label.text = "Ограничение 38 символов"
        label.font = .systemFont(ofSize: UIConstants.signsLimitLabelFontSize)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(HabitOrEventCategoryCell.self,
                           forCellReuseIdentifier: HabitOrEventCategoryCell.habitCategoryCellIdentifier)
        tableView.register(HabitOrEventScheduleCell.self,
                           forCellReuseIdentifier: HabitOrEventScheduleCell.habitScheduleCellIdentifier)
        tableView.bounces = false
        return tableView
    }()
    
    private lazy var emojisCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EmojisCollectionViewCell.self,
                                forCellWithReuseIdentifier: EmojisCollectionViewCell.emojisCollectionViewCellIdentifier)
        collectionView.register(SupplementaryEmojisView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "emojisHeader")
        collectionView.tag = 1
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
        
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView =  UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var colorsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ColorsCollectionViewCell.self,
                                forCellWithReuseIdentifier: ColorsCollectionViewCell.ColorsCollectionViewCellIdentifier)
        collectionView.register(SupplementaryColorsView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "colorsHeader")
        collectionView.tag = 2
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UIConstants.cancelButtonFontSize)
        button.setTitleColor(.ypRed, for: .normal)
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = UIConstants.cancelButtonCornerRadius
        button.layer.masksToBounds = true
        button.addTarget(self,
                         action: #selector(didTapCancelButton),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UIConstants.createButtonFontSize)
        button.backgroundColor = .ypGray
        button.isEnabled = false
        button.layer.cornerRadius = UIConstants.createButtonCornerRadius
        button.layer.masksToBounds = true
        button.addTarget(self,
                         action: #selector(didTapCreateButton),
                         for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    private func updateCreateButtonAvailability() {
        let textIsValid = textField.text?.isEmpty == false
        let categoriesAreSelected = selectedCategory != nil && !(selectedCategory!.title.isEmpty)
        let daysAreSelected = !selectedDays.isEmpty
        let emojiIsSelected = selectedEmoji != nil
        let colorIsSelected = selectedColor != nil
        let shouldEnableButton: Bool
        
        shouldEnableButton = textIsValid && categoriesAreSelected && emojiIsSelected && colorIsSelected && (!isHabit || daysAreSelected)
        
        createButton.isEnabled = shouldEnableButton
        createButton.backgroundColor = shouldEnableButton ? .ypBlack : .ypGray
    }
    
    private func makeTracker() -> Tracker {
        let name = textField.text ?? ""
        let id = UUID()
        let today = Date()
        var schedule: [DayOfWeek] = []
        
        if isHabit {
            schedule = selectedDays
        } else {
            var filterWeekDay = Calendar.current.component(.weekday, from: today)
            if filterWeekDay == 1 {
                filterWeekDay = 7
            } else {
                filterWeekDay -= 1
            }
            if let selectedDayOfWeek = DayOfWeek(rawValue: filterWeekDay){
                schedule.append(selectedDayOfWeek)
            }
        }
        
        return Tracker(id: id,
                       name: name,
                       color: selectedColor ?? UIColor(white: 1, alpha: 1),
                       emoji: selectedEmoji ?? "",
                       schedule: schedule,
                       isHabit: isHabit)
    }
    
    @objc private func didTapCancelButton() {
        selectedDays.removeAll()
        selectedEmoji = nil
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        if let category = selectedCategory {
            do {
                try trackerDataProvider?.addTracker(makeTracker(),
                                                    for: category)
                print(category.trackers)
            } catch {
                print("Failed to create a tracker for the category: \(category)")
            }
        }
        
        let tabBarController = TabBarController()
        let navigationController = UINavigationController(rootViewController: tabBarController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        navigationController.setNavigationBarHidden(true, animated: true)
    }
    
    @objc private func didTapClearTextFieldButton() {
        textField.text = ""
        signsLimitLabel.isHidden = true
    }
    
    private func chooseHabitOrIrregularEvent() {
        titleLabel.text = isHabit ? "Новая привычка" : "Нерегулярное событие"
        tableView.reloadData()
    }
    
    private func getCollectionHeight() -> CGFloat {
        let availableWidth = view.frame.width - params.paddingWidth
        let cellHeight = availableWidth / CGFloat(params.cellCount)
        
        let num = cellHeight * 4.5
        let collectionSize = CGFloat(num)
        
        return collectionSize
    }
}

extension HabitOrEventViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 1:
            return emojis.count
        case 2:
            return colors.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojisCollectionViewCell.emojisCollectionViewCellIdentifier, for: indexPath) as? EmojisCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.updateEmojiLabel(emoji: emojis[indexPath.row])
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorsCollectionViewCell.ColorsCollectionViewCellIdentifier, for: indexPath) as? ColorsCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.updateColor(color: colors[indexPath.row])
            return cell
        default:
            return UICollectionViewCell()
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: params.topInset, left: params.leftInset, bottom: params.bottomInset, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch collectionView.tag {
        case 1:
            guard kind == UICollectionView.elementKindSectionHeader,
                  let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "emojisHeader",
                                                                             for: indexPath) as? SupplementaryEmojisView else {
                return UICollectionReusableView()
            }
            view.updateTitleLabel(title: "Emoji")
            return view
        case 2:
            guard kind == UICollectionView.elementKindSectionHeader,
                  let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "colorsHeader",
                                                                             for: indexPath) as? SupplementaryColorsView else {
                return UICollectionReusableView()
            }
            view.updateTitleLabel(text: "Цвет")
            return view
        default:
            return UICollectionReusableView()
        }
    }
}

extension HabitOrEventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth = availableWidth / CGFloat(params.cellCount)
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

extension HabitOrEventViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case 1:
            let selectedEmoji = emojis[indexPath.row]
            if let cell = emojisCollectionView.cellForItem(at: indexPath) as? EmojisCollectionViewCell {
                cell.updateEmojiBackgroundColor(color: .ypLightGray)
            }
            self.selectedEmoji = selectedEmoji
            updateCreateButtonAvailability()
        case 2:
            let selectedColor = colors[indexPath.row]
            if let cell = colorsCollectionView.cellForItem(at: indexPath) as? ColorsCollectionViewCell {
                cell.updateColorFrame(color: selectedColor, isHidden: false)
            }
            self.selectedColor = selectedColor
            updateCreateButtonAvailability()
        default:
            print ("")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case 1:
            if let cell = emojisCollectionView.cellForItem(at: indexPath) as? EmojisCollectionViewCell {
                cell.updateEmojiBackgroundColor(color: .clear)
            }
            self.selectedEmoji = nil
            updateCreateButtonAvailability()
        case 2:
            if let cell = colorsCollectionView.cellForItem(at: indexPath) as? ColorsCollectionViewCell {
                cell.updateColorFrame(color: colors[indexPath.row], isHidden: true)
            }
            self.selectedColor = nil
            updateCreateButtonAvailability()
        default:
            print("")
        }
    }
}

extension HabitOrEventViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        let newText = (text as NSString).replacingCharacters(in: range, with: string)
        
        let maxLength = 38
        
        let isValid = newText.count <= maxLength
        signsLimitLabel.isHidden = isValid
        tableViewTopConstraint?.constant = isValid ? 24 : 48
        updateCreateButtonAvailability()
        return isValid
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        updateCreateButtonAvailability()
        return true
    }
}

extension HabitOrEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath ) {
        switch indexPath.row {
        case 0:
            let viewModel = CategoryViewModel()
            let categoryViewController = CategoryViewController(delegate: self, selectedCategory: selectedCategory, viewModel: viewModel  )
            categoryViewController.delegate = self
            present(categoryViewController, animated: true)
        default:
            let scheduleViewController = ScheduleViewController(delegate: self, selectedDays: selectedDays)
            scheduleViewController.delegate = self
            present(scheduleViewController, animated: true)
        }
    }
}

extension HabitOrEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isHabit ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isHabit {
            switch indexPath.row {
            case 0:
                return habitOrEventCategoryCell(for: indexPath, in: tableView, isLastCell: false)
            default:
                return habitOrEventScheduleCell(for: indexPath, in: tableView, isLastCell: true)
            }
        } else {
            return habitOrEventCategoryCell(for: indexPath, in: tableView, isLastCell: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    private func habitOrEventCategoryCell(for indexPath: IndexPath, in tableView: UITableView, isLastCell: Bool) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitOrEventCategoryCell.habitCategoryCellIdentifier, for: indexPath) as? HabitOrEventCategoryCell else {
            return UITableViewCell()
        }
        
        configureSeparator(for: cell, isLastCell: isLastCell)
        configureCornerRadius(for: cell, indexPath: indexPath)
        
        let selectedCategoriesString = selectedCategory?.title ?? ""
        cell.changeCategoriesLabel(categories: selectedCategoriesString)
        return cell
    }
    
    private func habitOrEventScheduleCell(for indexPath: IndexPath, in tableView: UITableView, isLastCell: Bool) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitOrEventScheduleCell.habitScheduleCellIdentifier, for: indexPath) as? HabitOrEventScheduleCell else {
            return UITableViewCell()
        }
        configureSeparator(for: cell, isLastCell: isLastCell)
        configureCornerRadius(for: cell, indexPath: indexPath)
        
        let selectedDaysString = selectedDays.map { day in
            switch day {
            case .monday:
                return("Пн")
            case .tuesday:
                return("Вт")
            case .wednesday:
                return("Ср")
            case .thursday:
                return("Чт")
            case .friday:
                return("Пт")
            case .saturday:
                return("Сб")
            case .sunday:
                return("Вс")
            }
        }.joined(separator: ", ")
        cell.changeDaysLabel(days: selectedDaysString)
        return cell
    }
    
    private func configureSeparator(for cell: UITableViewCell, isLastCell: Bool) {
        if isLastCell {
            cell.separatorInset = UIEdgeInsets(top: 0, left: .greatestFiniteMagnitude, bottom: 0, right: 16)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    private func configureCornerRadius(for cell: UITableViewCell, indexPath: IndexPath) {
        let cornerRadius = UIConstants.HabitOrEventCategoryCellCornerRadius
        
        if isHabit {
            switch indexPath.row {
            case 0:
                cell.layer.cornerRadius = cornerRadius
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            case 1:
                cell.layer.cornerRadius = cornerRadius
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            default:
                cell.layer.cornerRadius = 0
                cell.layer.maskedCorners = []
            }
        } else {
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMinYCorner,
                                        .layerMaxXMinYCorner,
                                        .layerMinXMaxYCorner,
                                        .layerMaxXMaxYCorner]
        }
        
        cell.layer.masksToBounds = true
    }
}

extension HabitOrEventViewController: CategoryViewControllerDelegate {
    func didSelect(category: TrackerCategory?) {
        selectedCategory = category
        tableView.reloadData()
        updateCreateButtonAvailability()
    }
}

extension HabitOrEventViewController: ScheduleViewControllerDelegate{
    func didSelect(days: [DayOfWeek]) {
        selectedDays = days
        tableView.reloadData()
        updateCreateButtonAvailability()
    }
}

extension HabitOrEventViewController: TrackerDataProviderDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        
    }
}

extension HabitOrEventViewController {
    private func initialize() {
        textField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        view.backgroundColor = .systemBackground
        
        [titleLabel,
         scrollView].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)}
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        [textField,
         signsLimitLabel,
         tableView,
         cancelButton,
         createButton,
         emojisCollectionView,
         colorsCollectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        [emojisCollectionView, colorsCollectionView].forEach{
            view.bringSubviewToFront($0)
        }
        
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.widthAnchor.constraint(equalToConstant: 400),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            signsLimitLabel.heightAnchor.constraint(equalToConstant: 32),
            signsLimitLabel.widthAnchor.constraint(equalToConstant: 286),
            signsLimitLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            signsLimitLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            tableView.heightAnchor.constraint(equalToConstant: isHabit ? 150 : 75),
            tableViewTopConstraint!,
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            emojisCollectionView.heightAnchor.constraint(equalToConstant: getCollectionHeight()),
            emojisCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojisCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojisCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            colorsCollectionView.heightAnchor.constraint(equalToConstant: getCollectionHeight()),
            colorsCollectionView.topAnchor.constraint(equalTo: emojisCollectionView.bottomAnchor, constant: 16),
            colorsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: view.frame.width / 2 - 24),
            cancelButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalToConstant: view.frame.width / 2 - 24),
            createButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
    }
}
