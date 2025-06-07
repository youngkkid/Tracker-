import Foundation

final class CategoryViewModel: CategoryViewModelProtocol {
    
    var categoryCreated: CategoryBinding<[IndexPath]>?
    var categoryDeleted: CategoryBinding<[IndexPath]>?
    var categoryUpdated: CategoryBinding<[IndexPath]>?
    var onErrorStateChanged: CategoryBinding<String>?
    
    private var insertedIndexPaths: [IndexPath]?
    private var deletedIndexPaths: [IndexPath]?
    private var updatedIndexPaths: [IndexPath]?
    
    private lazy var trackerCategoryDataProvider: TrackerCategoryDataProviderProtocol? = {
        let trackerCategoryDataStore = TrackerCategoryStore()
        
        do {
            try trackerCategoryDataProvider = TrackerCategoryDataProvider(trackerCategoryStore: trackerCategoryDataStore,
                                                                       delegate: self)
            return trackerCategoryDataProvider
        } catch {
            onErrorStateChanged?("Failed to initialize TrackerCategoryDataProvider")
            return nil
        }
    }()
    
    func fetchCategories() -> [TrackerCategory]? {
        trackerCategoryDataProvider?.fetchCategories()
    }
    
    func numberOfSections() -> Int {
        trackerCategoryDataProvider?.numberOfSections ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        trackerCategoryDataProvider?.numberOfRowsInSection(section) ?? 0
    }
    
    func editCategory(at indexPath: IndexPath) -> TrackerCategory? {
        trackerCategoryDataProvider?.object(at: indexPath)
    }
    
    func deleteCategory(at indexPath: IndexPath) {
        guard let category = editCategory(at: indexPath) else {return}
        
        do {
            try trackerCategoryDataProvider?.deleteCategory(with: category.title)
            categoryDeleted?(deletedIndexPaths ?? [])
        } catch {
            onErrorStateChanged?("Failed to delete category")
        }
    }
    
    func createCategory(_ category: TrackerCategory) {
        do {
            try trackerCategoryDataProvider?.createCategory(category)
            categoryCreated?(insertedIndexPaths ?? [])
        } catch {
            onErrorStateChanged?("Failed to create category")
        }
    }
    
    func updateCategory(_ category: TrackerCategory, with newTitle: String) {
        do {
            try trackerCategoryDataProvider?.updateCategory(category, with: newTitle)
            categoryUpdated?(updatedIndexPaths ?? [])
        } catch {
            onErrorStateChanged?("Failed to update category")
        }
    }
}


extension CategoryViewModel: TrackerCategoryDataProviderDelegate {
    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
        insertedIndexPaths = update.insertedIndexes.map { IndexPath(row: $0, section: 0)}
        deletedIndexPaths = update.deletedIndexes.map { IndexPath(row: $0, section: 0)}
        updatedIndexPaths = update.updatedIndexes.map {IndexPath(row: $0, section: 0)}
    }
}
