import CoreData

protocol TrackerDataStore {
    var managedObjectContext: NSManagedObjectContext? { get }
    func add(_ tracker: Tracker, for category: TrackerCategory) throws
}
