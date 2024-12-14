//
//  FileEntity+CoreDataProperties.swift
//  LanguageLearningApp
//
//  Created by Farida on 02.12.2024.
//
//

import Foundation
import CoreData


extension FileEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FileEntity> {
        return NSFetchRequest<FileEntity>(entityName: "FileEntity")
    }

    @NSManaged public var count: Int32
    @NSManaged public var name: String?
    @NSManaged public var originalLanguage: String?
    @NSManaged public var translationLanguage: String?
    @NSManaged public var translation: NSSet?

}

// MARK: Generated accessors for translation
extension FileEntity {

    @objc(addTranslationObject:)
    @NSManaged public func addToTranslation(_ value: TranslationResultEntity)

    @objc(removeTranslationObject:)
    @NSManaged public func removeFromTranslation(_ value: TranslationResultEntity)

    @objc(addTranslation:)
    @NSManaged public func addToTranslation(_ values: NSSet)

    @objc(removeTranslation:)
    @NSManaged public func removeFromTranslation(_ values: NSSet)

}

extension FileEntity : Identifiable {

}
