//
//  PreTaskQuestionsEntity.swift
//  QualityExpertise
//
//  Created by Amarjith B on 27/10/25.
//


import CoreData

@objc(PreTaskQuestionsEntity)
class PreTaskQuestionsEntity: NSManagedObject {
    
    @NSManaged public var id: Int64
    @NSManaged public var contentId: Int64
    @NSManaged public var title: String
    @NSManaged public var imageUrl: String?
    @NSManaged public var updatedTime: String
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PreTaskQuestionsEntity> {
        return NSFetchRequest<PreTaskQuestionsEntity>(entityName: "PreTaskQuestionsEntity")
    }
}
