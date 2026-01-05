//
//  AuditItemEntity.swift
//  QualityExpertise
//
//  Created by Amarjith B on 08/08/25.
//

import CoreData

@objc(AuditItemEntity)
class AuditItemEntity: NSManagedObject {
    
    @NSManaged public var id: Int64
    @NSManaged public var auditItemId: Int64
    @NSManaged public var auditItemTitle: String
    @NSManaged public var image: String
    @NSManaged public var updatedTime: String
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AuditItemEntity> {
        return NSFetchRequest<AuditItemEntity>(entityName: "AuditItemEntity")
    }
}
