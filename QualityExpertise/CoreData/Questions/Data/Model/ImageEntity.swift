//
//  ImageEntity.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

import CoreData

@objc(ImageEntity)
class ImageEntity: NSManagedObject {
    @NSManaged public var image: String?
    @NSManaged public var desc: String?
    @NSManaged public var violation: ViolationEntity

}
