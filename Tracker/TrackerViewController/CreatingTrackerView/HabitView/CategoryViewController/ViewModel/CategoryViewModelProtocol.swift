import Foundation

protocol CategoryViewModelProtocol {
    var categoryCreated: CategoryBinding<[IndexPath]>? { get set }
    var categoryDeleted: CategoryBinding<[IndexPath]>? { get set }
    var categoryUpdated: CategoryBinding<[IndexPath]>? { get set }
    var onErrorStateChanged: CategoryBinding<String>? { get set }

    func fetchCategories() -> [TrackerCategory]?
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func editCategory(at indexPath: IndexPath) -> TrackerCategory?
    func deleteCategory(at indexPath: IndexPath)
    func createCategory(_ category: TrackerCategory)
    func updateCategory(_ category: TrackerCategory, with newTitle: String)
}
