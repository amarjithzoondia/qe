//
//  LessonEntity.swift
//  QualityExpertise
//
//  Created by Amarjith B on 29/07/25.
//

import CoreData

@objc(LessonEntity)
class LessonEntity: NSManagedObject {
    @NSManaged public var createdAt: String
    @NSManaged public var id: Int64
    @NSManaged public var title: String
    @NSManaged public var desc: String?
    @NSManaged public var facilities: GroupEntity?
    @NSManaged public var images: NSSet?
    @NSManaged public var reportedBy: String
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LessonEntity> {
        return NSFetchRequest<LessonEntity>(entityName: "LessonEntity")
    }
}
