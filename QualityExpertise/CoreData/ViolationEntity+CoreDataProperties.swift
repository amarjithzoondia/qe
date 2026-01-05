//
//  ViolationEntity+CoreDataProperties.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//
//

import Foundation
import CoreData


extension ViolationEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ViolationEntity> {
        return NSFetchRequest<ViolationEntity>(entityName: "ViolationEntity")
    }

    @NSManaged public var createdAt: String?
    @NSManaged public var employeeId: String?
    @NSManaged public var employeeName: String?
    @NSManaged public var id: Int64
    @NSManaged public var location: String?
    @NSManaged public var violationDate: String?
    @NSManaged public var violationDescription: String?
    @NSManaged public var facilities: GroupEntity?
    @NSManaged public var images: NSSet?

}

// MARK: Generated accessors for images
extension ViolationEntity { 

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: ImageEntity)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: ImageEntity)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}

extension ViolationEntity : Identifiable {

}
