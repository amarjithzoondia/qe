//
//  ToolBoxEntity.swift
//  QualityExpertise
//
//  Created by Amarjith B on 16/09/25.
//

import CoreData

@objc(ToolBoxEntity)
class ToolBoxEntity: NSManagedObject {
    
    @NSManaged public var id: Int64
    @NSManaged public var date: String
    @NSManaged public var startTime: String
    @NSManaged public var endTime: String
    @NSManaged public var topic: String
    @NSManaged public var discussionPoints: Data
    @NSManaged public var attendantedEmployees: Data
    @NSManaged public var createdAt: String
    @NSManaged public var facilities: GroupEntity?
    @NSManaged public var images: NSSet?
    @NSManaged public var reportedBy: String
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToolBoxEntity> {
        return NSFetchRequest<ToolBoxEntity>(entityName: "ToolBoxEntity")
    }
}
