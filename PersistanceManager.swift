import Foundation
import CoreData

final class PersistanceManager {
    // MARK: - Core Data stack

    private init() {}
    static let shared = PersistanceManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
       
        let persistentContainer = NSPersistentCloudKitContainer(name: "NAME")
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
               
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return persistentContainer
    }()
    
    lazy var context = persistentContainer.viewContext

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetch<T: NSManagedObject>(_ objectType: T.Type) -> [T] {
        
        let entityName = String(describing: objectType)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            let fetchedObjects = try context.fetch(fetchRequest) as? [T]
            return fetchedObjects ?? [T]()
        } catch {
            print(error)
            return [T]()
        }
    }

    func buildFRC<T:NSManagedObject>(managedObjectContext:NSManagedObjectContext, entity: T.Type, sortKey: String) -> NSFetchedResultsController<T>? {
        let fetchedResultController: NSFetchedResultsController<T>
                  
        let request: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
                  let sort = NSSortDescriptor(key: sortKey, ascending: true)
                  request.sortDescriptors = [sort]
                  
        fetchedResultController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
                  
                  do {
                      try fetchedResultController.performFetch()
                  }
                  catch {
                      fatalError("Error in fetching records")
                  }
                  
        return fetchedResultController
              }
    }
