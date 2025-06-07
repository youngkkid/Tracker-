import Foundation
import CoreData

final class TrackerStore {
    private var context: NSManagedObjectContext
    
    convenience init() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

extension TrackerStore: TrackerDataStore {
    var managedObjectContext: NSManagedObjectContext? {
        context
    }

    func add(_ tracker: Tracker, for category: TrackerCategory) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), category.title)
        guard let trackerCategoryCoreData = try? context.fetch(request).first else { return }
        
        trackerCoreData.name = tracker.name
        trackerCoreData.id = tracker.id
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color.hexString
        trackerCoreData.isHabit = tracker.isHabit
        trackerCoreData.trackerCategory = trackerCategoryCoreData
        trackerCategoryCoreData.addToTrackers(trackerCoreData)
        
        do {
            let encodeSchedule = try JSONEncoder().encode(tracker.schedule)
            trackerCoreData.schedule = encodeSchedule
        } catch {
            print("Error coding of schedule: \(error)")
        }
        
        CoreDataManager.shared.saveContext()
    }
}
