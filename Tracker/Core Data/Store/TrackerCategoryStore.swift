import UIKit
import CoreData

final class TrackerCategoryStore {
    private var context: NSManagedObjectContext
    
    convenience init() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
}

extension TrackerCategoryStore: TrackerCategoryDataStore {
    var managedObjectContext: NSManagedObjectContext? {
        context
    }
    
    func create(_ category: TrackerCategory) {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.title = category.title
        trackerCategoryCoreData.trackers = []
        CoreDataManager.shared.saveContext()
    }
    
    func fetchCategories() -> [TrackerCategory] {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        
        do {
            let trackerCategories = try context.fetch(request)
            
            return trackerCategories.map { categoryCoreData in
                let title = categoryCoreData.title ?? ""
                let trackers = categoryCoreData.trackers?.allObjects as? [TrackerCoreData] ?? []
                let trackerObjects = trackers.compactMap { trackerCoreData in
                    return Tracker(trackerCoreData: trackerCoreData)
                }
                return TrackerCategory(title: title, trackers: trackerObjects)
            }
        } catch {
            print("Filed to fetch categories: \(error)")
            return []
        }
    }
}
