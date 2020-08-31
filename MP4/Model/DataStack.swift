//
//  DataStack.swift
//  MP4
//
//  Created by Oti Oritsejafor on 10/30/19.
//  Copyright © 2019 Magloboid. All rights reserved.
//

import Foundation
import CoreData

class DataStack {
    static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RunTown")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
     static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    class func saveContext () {
        let context = persistentContainer.viewContext
        
        guard context.hasChanges else {
            return
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
