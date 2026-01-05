//
//  GroupEntity.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

import CoreData

@objc(GroupEntity)
class GroupEntity: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var code: String
    @NSManaged public var image: String
}
