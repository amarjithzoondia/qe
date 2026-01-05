//
//  ObservationEntity.swift
//  QualityExpertise
//
//  Created by Amarjith B on 05/01/26.
//


import CoreData

@objc(ObservationEntity)
class ObservationEntity: NSManagedObject {
    
    @NSManaged public var observationId: Int64
    @NSManaged public var observationTitle: String
    @NSManaged public var reportedBy: String
    @NSManaged public var location: String?
    @NSManaged public var descriptions: String?
    @NSManaged public var responsiblePersonName: String?
    @NSManaged public var responsiblePersonEmail: String?
    @NSManaged public var projectResponsiblePerson: Data?
    @NSManaged public var sendNotification: Data?
    @NSManaged public var createdAt: String
    @NSManaged public var facilities: GroupEntity?
    @NSManaged public var images: NSSet?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ObservationEntity> {
        return NSFetchRequest<ObservationEntity>(entityName: "ObservationEntity")
    }
}
