import Foundation
import CoreData

struct TrackerStoreUpdate {
    let insertIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerDataProviderProtocol {
    var numbersOfSections: Int {get}
    func numbersOfRowInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> Tracker?
    func addTracker(_ tracker: Tracker, for category: TrackerCategory) throws
    func clearData() throws
}

protocol TrackerDataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

final class TrackerDataProvider: NSObject {
    enum TrackerDataProviderError: Error {
        case failedToInitializeContext
    }
    
    weak var delegate: TrackerDataProviderDelegate?
    
    private let context: NSManagedObjectContext
    private let trackerDataStore: TrackerDataStore
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    private var insertIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    init(trackerStore: TrackerDataStore, delegate: TrackerDataProviderDelegate) throws {
        guard let context = trackerStore.managedObjectContext else {
            throw TrackerDataProviderError.failedToInitializeContext
        }
        self.delegate = delegate
        self.context = context
        self.trackerDataStore = trackerStore
    }
}

extension TrackerDataProvider: TrackerDataProviderProtocol {
    var numbersOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numbersOfRowInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return Tracker(trackerCoreData: trackerCoreData)
    }
    
    func addTracker(_ tracker: Tracker, for category: TrackerCategory) throws {
        try? trackerDataStore.add(tracker, for: category)
    }
    
    func clearData() throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCoreData")
        do {
            let results = try context.fetch(request)
            for result in results as? [NSManagedObject] ?? [] {
                context.delete(result)
            }
            try context.save()
        } catch {
            throw error
        }
    }
}

extension TrackerDataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let insertIndexes = insertIndexes,
              let deletedIndexes = deletedIndexes else {
            return
        }
        delegate?.didUpdate(
            .init(insertIndexes: insertIndexes,
                  deletedIndexes: deletedIndexes))
        self.insertIndexes = nil
        self.deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = indexPath {
                insertIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}
