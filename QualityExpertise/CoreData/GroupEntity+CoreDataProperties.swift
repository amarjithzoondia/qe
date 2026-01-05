//
//  GroupEntity+CoreDataProperties.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//
//

import Foundation
import CoreData


extension GroupEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroupEntity> {
        return NSFetchRequest<GroupEntity>(entityName: "GroupEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var code: String?
    @NSManaged public var image: String?

}

extension GroupEntity : Identifiable {

}
