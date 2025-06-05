import Foundation

protocol AddCategoryViewControllerDelegate: NSObject {
    func add(category: TrackerCategory)
    func update(_ category: TrackerCategory, with newTitle: String)
}
