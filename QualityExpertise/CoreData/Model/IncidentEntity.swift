//
//  IncidentEntity.swift
//  QualityExpertise
//
//  Created by Amarjith B on 11/09/25.
//

import CoreData

@objc(IncidentEntity)
class IncidentEntity: NSManagedObject {
    
    @NSManaged public var id: Int64
    @NSManaged public var incidentDate: String
    @NSManaged public var incidentTime: String
    @NSManaged public var incidentLocation: String?
    @NSManaged public var incidentType: Data?
    @NSManaged public var injuredEmployees: Data?
    @NSManaged public var descriptions: String?
    @NSManaged public var corrections: String?
    @NSManaged public var createdAt: String
    @NSManaged public var facilities: GroupEntity?
    @NSManaged public var images: NSSet?
    @NSManaged public var reportedBy: String
    @nonobjc public class func fetchRequest() -> NSFetchRequest<IncidentEntity> {
        return NSFetchRequest<IncidentEntity>(entityName: "IncidentEntity")
    }
}
