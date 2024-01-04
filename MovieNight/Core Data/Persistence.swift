//
//  Persistence.swift
//  MovieNight
//
//  Created by Boone on 8/12/23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        #warning("TODO: Support Versioning for the container name")
        // Name of the schema
        container = NSPersistentContainer(name: "MovieNight")

        if inMemory {
            // tells Core Data to not actaully use a file (don't store something)
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // MARK: SwiftUI Preview
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

//        for index in 1..<10 {
//            let newItem = CDMovieResult(context: viewContext)
//            newItem.titleText?.text = "Movie \(index)"
//        }

        return controller
    }()
}
