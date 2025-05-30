import Foundation

final class DataManager {
    static let shared = DataManager()
    
    var categories: [TrackerCategory] = []
    
    private init() {}
    
    func add(category: TrackerCategory){
        categories.append(category)
    }
}
