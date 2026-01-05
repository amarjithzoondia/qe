//
//  PreTaskEntity.swift
//  QualityExpertise
//
//  Created by Amarjith B on 27/10/25.
//


import CoreData

@objc(PreTaskEntity)
class PreTaskEntity: NSManagedObject {
    
    @NSManaged public var id: Int64
    @NSManaged public var date: String
    @NSManaged public var msraReference: String?
    @NSManaged public var startTime: String
    @NSManaged public var endTime: String
    @NSManaged public var permitReference: String?
    @NSManaged public var taskTitle: String
    @NSManaged public var contents: Data
    @NSManaged public var questions: Data
    @NSManaged public var otherTopic: Data
    @NSManaged public var attendees: Data
    @NSManaged public var createdAt: String
    @NSManaged public var facilities: GroupEntity?
    @NSManaged public var images: NSSet?
    @NSManaged public var reportedBy: String
    @NSManaged public var notes: String?
    @NSManaged public var sendNotificationTo: Data?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PreTaskEntity> {
        return NSFetchRequest<PreTaskEntity>(entityName: "PreTaskEntity")
    }
}
