//
//  CoreDataStorage.swift
//  RssReader
//
//  Created by sergey maklakov on 07.08.17.
//  Copyright © 2017 sergey maklakov. All rights reserved.
//

import CoreData

class CoreDataStorage: Storage {

    private(set) var context: NSManagedObjectContext

    init() {
        let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        let databaseRootUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let databaseUrl = databaseRootUrl.appendingPathComponent("Model.sqlite")
        let options: [AnyHashable: Any] = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                               configurationName: nil,
                                               at: databaseUrl,
                                               options: options)
        } catch {
            print("recreate database")
            do {
                try FileManager.default.removeItem(at: databaseUrl)
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                   configurationName: nil,
                                                   at: databaseUrl,
                                                   options: options)

            } catch {
                print(error)
                abort()
            }
        }
        context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
    }

    deinit {
        context.performAndWait {
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    print(error)
                }
            }
        }
    }

    func fetch<T>(entityName: String,
                  predicate: NSPredicate?,
                  callback: (([T]?, Error?) -> Void)?) where T: DatabaseObject {
        context.perform {
            do {
                let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
                request.predicate = predicate
                let managedObjects = try self.context.fetch(request)
                let parsedObjects: [T?] = managedObjects.map({ T(managedObject: $0) })
                let validObjects: [T?] = parsedObjects.filter({ $0 != nil })
                let result: [T] = validObjects.map({ $0! })
                DispatchQueue.main.async {
                    callback?(result, nil)
                }
            } catch {
                print(error)
                DispatchQueue.main.async {
                    callback?(nil, error)
                }
            }
        }
    }

    func insert<T>(objects: [T],
                   entityName: String,
                   callback: ((Error?) -> Void)?) where T: DatabaseObject {
        context.perform {
            do {
                for object in objects {
                    let managedObject = NSEntityDescription.insertNewObject(forEntityName: entityName,
                                                                            into: self.context)
                    object.save(managedObject: managedObject)
                }
                try self.context.save()
                DispatchQueue.main.async {
                    callback?(nil)
                }
            } catch {
                print(error)
                DispatchQueue.main.async {
                    callback?(error)
                }
            }
        }
    }

    func remove(entityName: String,
                predicate: NSPredicate?,
                callback: ((Error?) -> Void)?) {
        context.perform {
            do {
                let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
                request.predicate = predicate
                request.includesSubentities = false
                request.includesPropertyValues = false
                let managedObjects = try self.context.fetch(request)
                for managedObject in managedObjects {
                    self.context.delete(managedObject)
                }
                DispatchQueue.main.async {
                    callback?(nil)
                }
            } catch {
                print(error)
                DispatchQueue.main.async {
                    callback?(nil)
                }
            }
        }
    }
}
