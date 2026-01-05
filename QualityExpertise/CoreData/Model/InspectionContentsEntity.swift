//
//  InspectionContentsEntity.swift
//  QualityExpertise
//
//  Created by Amarjith B on 08/08/25.
//

import CoreData

@objc(InspectionContentsEntity)
class InspectionContentsEntity: NSManagedObject {
    
    @NSManaged public var auditItemId: Int64
    @NSManaged public var updatedTime: String
//    @NSManaged public var formVersion: String
    @NSManaged public var contents: Data
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<InspectionContentsEntity> {
        return NSFetchRequest<InspectionContentsEntity>(entityName: "InspectionContentsEntity")
    }
}
