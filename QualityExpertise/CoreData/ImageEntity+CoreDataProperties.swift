//
//  ImageEntity+CoreDataProperties.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//
//

import Foundation
import CoreData


extension ImageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageEntity> {
        return NSFetchRequest<ImageEntity>(entityName: "ImageEntity")
    }

    @NSManaged public var image: String?
    @NSManaged public var imageDescription: String?
    @NSManaged public var violation: ViolationEntity?

}

extension ImageEntity : Identifiable {

}
