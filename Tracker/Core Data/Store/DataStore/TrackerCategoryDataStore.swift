import CoreData

protocol TrackerCategoryDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func create(_ category: TrackerCategory) throws
    func fetchCategories()  -> [TrackerCategory]
}
