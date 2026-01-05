//
//  InspectionEntity.swift
//  QualityExpertise
//
//  Created by Amarjith B on 01/08/25.
//

import CoreData

@objc(InspectionEntity)
class InspectionEntity: NSManagedObject {
    @NSManaged public var createdAt: String
    @NSManaged public var id: Int64
    @NSManaged public var inspectionId: Int64
    @NSManaged public var inspectionName: String
    @NSManaged public var modelNumber: String?
    @NSManaged public var inspectedBy: String
    @NSManaged public var location: String?
    @NSManaged public var inspectionDate: String?
    @NSManaged public var staticEquipmentData: Data?
    @NSManaged public var desc: String?
    @NSManaged public var notes: String?
    @NSManaged public var questionsUpdatedTime: String?
    @NSManaged public var formUpdatedTime: String?
    @NSManaged public var facilities: GroupEntity?
    @NSManaged public var equipmentSource: Int64
    @NSManaged public var rentalOrSubContractor: String?
    @NSManaged public var images: NSSet?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<InspectionEntity> {
        return NSFetchRequest<InspectionEntity>(entityName: "InspectionEntity")
    }
}
