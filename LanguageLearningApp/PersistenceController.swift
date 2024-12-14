//
//  PersistenceController.swift
//  LanguageLearningApp
//
//  Created by Farida on 02.12.2024.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // Замените "YourDataModelName" на имя вашей модели данных (.xcdatamodeld)
        container = NSPersistentContainer(name: "DataModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // Обработка ошибки
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}

