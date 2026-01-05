//
//  InspectionAnswersEntity.swift
//  QualityExpertise
//
//  Created by Amarjith B on 04/08/25.
//

import CoreData

@objc(InspectionAnswersEntity)
class InspectionAnswersEntity: NSManagedObject {
    
    @NSManaged public var id: Int64
    @NSManaged public var inspectionId: Int64
    @NSManaged public var questionId: Int64
    @NSManaged public var answerType: Int64
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<InspectionAnswersEntity> {
        return NSFetchRequest<InspectionAnswersEntity>(entityName: "InspectionAnswersEntity")
    }
}
