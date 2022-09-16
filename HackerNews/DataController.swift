//
//  DataController.swift
//  HackerNewsReader
//
//  Created by Michael Hsieh on 9/15/22.
//

import CoreData
import Foundation

class DataController:ObservableObject {
    let container = NSPersistentContainer(name: "NewsApp")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
