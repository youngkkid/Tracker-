import Foundation

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelect(category: TrackerCategory?)
}
