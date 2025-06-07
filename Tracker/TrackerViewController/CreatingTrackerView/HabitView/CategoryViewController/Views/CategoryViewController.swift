import UIKit

final class CategoryViewController: UIViewController {
    
    private enum UIConstants {
        static let titleLabelFontSize: CGFloat = 16
        static let placeholderLabelFontSize: CGFloat = 12
        static let addCategoryButtonFontSize: CGFloat = 16
        static let addCategoryButtonCornerRadius: CGFloat = 16
        static let categoryCellCornerRadius: CGFloat = 16
    }
    
    weak var delegate: CategoryViewControllerDelegate?
    
    private var selectedCategory: TrackerCategory? = nil
    private var viewModel: CategoryViewModelProtocol
    
    
    init(delegate: CategoryViewControllerDelegate? = nil, selectedCategory: TrackerCategory? = nil, viewModel: CategoryViewModelProtocol) {
        self.delegate = delegate
        self.selectedCategory = selectedCategory
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UIConstants.titleLabelFontSize)
        return label
    }()
    
    private lazy var tableView: UITableView =  {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(CategoryCell.self,
                           forCellReuseIdentifier: CategoryCell.categoryCellIdentifier)
        tableView.bounces = false
        tableView.layer.masksToBounds = true
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .placeholder
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.placeholderLabelFontSize)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "Привычки и события можно \n объединять по смыслу"
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UIConstants.addCategoryButtonFontSize)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = UIConstants.addCategoryButtonCornerRadius
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        setPlaceholderImage()
    }
    
    private func bind() {
        viewModel.categoryCreated = {[weak self] insertedIndexPaths in
            guard let self = self else {return}
            tableView.insertRows(at: insertedIndexPaths, with: .automatic)
            setPlaceholderImage()
        }
        
        viewModel.categoryUpdated = {[weak self] updatedIndexPaths in
            guard let self = self else {return}
            tableView.reloadRows(at: updatedIndexPaths, with: .automatic)
            setPlaceholderImage()
        }
        
        viewModel.categoryDeleted = {[weak self] deletedIndexPaths in
            guard let self = self else {return}
            tableView.deleteRows(at: deletedIndexPaths, with: .automatic)
            setPlaceholderImage()
        }
        
        viewModel.onErrorStateChanged = {[weak self] errorMessage in
            guard let self = self else {return}
            presentAlertController( message: errorMessage)
            setPlaceholderImage()
        }
    }
    
    private func setPlaceholderImage() {
        let trackerCategories = viewModel.fetchCategories()
        let isEmpty = trackerCategories?.isEmpty
        placeholderImageView.isHidden = !(isEmpty ?? true)
        placeholderLabel.isHidden = !(isEmpty ?? true)
    }
    
    private func presentAlertController(message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    @objc private func didTapCreateButton() {
        let addCategoryViewController = AddCategoryViewController(isEditingCategory: false)
        addCategoryViewController.delegate = self
        present(addCategoryViewController, animated: true)
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.categoryCellIdentifier, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        
        guard let trackerCategory = viewModel.editCategory(at: indexPath) else {
            return UITableViewCell()
        }
        cell.textLabel?.text = trackerCategory.title
        
        if selectedCategory != nil && cell.textLabel?.text == selectedCategory?.title {
            cell.setCheckMark()
        } else {
            cell.removeCheckMark()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = viewModel.editCategory(at: indexPath)
        delegate?.didSelect(category: selectedCategory)
        
        tableView.reloadData()
        
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPath.count > 0 else {return nil}
        
        let trackerCategory = viewModel.editCategory(at: indexPath)
        
        return UIContextMenuConfiguration(actionProvider: {actions in
            return UIMenu(
                children: [
                    UIAction(title: "Редактировать") {_ in
                        let addCategoryViewController = AddCategoryViewController(delegate: self, category: trackerCategory, isEditingCategory: true)
                        self.present(addCategoryViewController, animated: true)
                    },
                    UIAction(title: "Удалить", attributes: .destructive) {_ in
                        let alertController = UIAlertController(title: "", message: "Эта категория точно не нужна?", preferredStyle: .actionSheet)
                        
                        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                            self.viewModel.deleteCategory(at: indexPath)
                        }
                        
                        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
                        
                        alertController.addAction(deleteAction)
                        alertController.addAction(cancelAction)
                        
                        self.present(alertController, animated: true)
                    }
                ])
        })
    }
}

extension CategoryViewController: AddCategoryViewControllerDelegate {
    func update(_ category: TrackerCategory, with newTitle: String) {
        viewModel.updateCategory(category, with: newTitle)
    }
    
    func add(category: TrackerCategory) {
        viewModel.createCategory(category)
    }
}

extension CategoryViewController {
    private func initialize() {
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .systemBackground
        
        [titleLabel,
         tableView,
         placeholderImageView,
         placeholderLabel,
         addCategoryButton].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -24),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            placeholderImageView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -276),
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderImageView.centerXAnchor),
            
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}
