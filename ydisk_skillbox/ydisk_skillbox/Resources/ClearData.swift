//
//  ClearData.swift
//  ydisk_skillbox
//
//  Created by Никита Пивоваров on 04.10.2022.
//

import Foundation
import CoreData
import UIKit

struct ClearData {
    
    static func deleteAll() {
        
        // UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }
        // CoreData
        
        let appDel:AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.persistentContainer.viewContext
        let fetchRequests: [NSFetchRequest<NSFetchRequestResult>] = [
            NSFetchRequest<NSFetchRequestResult>(entityName: "FileItem"),
            NSFetchRequest<NSFetchRequestResult>(entityName: "FolderItem"),
            NSFetchRequest<NSFetchRequestResult>(entityName: "TableViewCellItem")
        ]
        for fetchRequest in fetchRequests {
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(fetchRequest)
                for managedObject in results {
                    if let managedObjectData: NSManagedObject = managedObject as? NSManagedObject {
                        context.delete(managedObjectData)
                    }
                }
            } catch let error as NSError {
                print("Deleted all my data in myEntity error : \(error) \(error.userInfo)")
            }
        }
    }
}
