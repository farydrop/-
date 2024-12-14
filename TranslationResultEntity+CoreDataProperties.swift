//
//  TranslationResultEntity+CoreDataProperties.swift
//  LanguageLearningApp
//
//  Created by Farida on 02.12.2024.
//
//

import Foundation
import CoreData


extension TranslationResultEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TranslationResultEntity> {
        return NSFetchRequest<TranslationResultEntity>(entityName: "TranslationResultEntity")
    }

    @NSManaged var score: Int16
    @NSManaged public var known: Bool
    @NSManaged public var reviewDate: Date?
    @NSManaged public var context: String?
    @NSManaged public var count: Int32
    @NSManaged public var id: Int32
    @NSManaged public var original: String?
    @NSManaged public var translate: String?
    @NSManaged public var file: FileEntity?

}

extension TranslationResultEntity : Identifiable {

}
