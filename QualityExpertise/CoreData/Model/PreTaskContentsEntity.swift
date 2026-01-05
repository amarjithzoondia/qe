//
//  PreTaskContentsEntity.swift
//  QualityExpertise
//
//  Created by Amarjith B on 27/10/25.
//

import CoreData

@objc(PreTaskContentsEntity)
class PreTaskContentsEntity: NSManagedObject {
    
    @NSManaged public var id: Int64
    @NSManaged public var title: String
    @NSManaged public var updatedTime: String
    @NSManaged public var order: Int64
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PreTaskContentsEntity> {
        return NSFetchRequest<PreTaskContentsEntity>(entityName: "PreTaskContentsEntity")
    }
}
