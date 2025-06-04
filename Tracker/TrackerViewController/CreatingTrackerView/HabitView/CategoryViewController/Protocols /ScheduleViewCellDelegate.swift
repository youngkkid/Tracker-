import Foundation

protocol AddCategoryViewControllerDelegate: AnyObject {
    func add(category: TrackerCategory)
    func update(_ category: TrackerCategory, with newTitle: String)
}
