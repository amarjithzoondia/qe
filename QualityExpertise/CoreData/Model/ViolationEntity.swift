//
//  ViolationEntity.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

import CoreData

@objc(ViolationEntity)
class ViolationEntity: NSManagedObject {
    @NSManaged public var createdAt: String
    @NSManaged public var employeeID: String
    @NSManaged public var employeeName: String
    @NSManaged public var id: Int64
    @NSManaged public var location: String?
    @NSManaged public var violationDate: String
    @NSManaged public var desc: String?
    @NSManaged public var facilities: GroupEntity?
    @NSManaged public var images: NSSet?
    @NSManaged public var reportedBy: String
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ViolationEntity> {
        return NSFetchRequest<ViolationEntity>(entityName: "ViolationEntity")
    }
}
