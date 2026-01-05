//
//  ImageEntity.swift
//  ALNASR
//
//  Created by Vivek M on 24/07/25.
//

import CoreData

@objc(ImageEntity)
class ImageEntity: NSManagedObject {
    @NSManaged public var image: String?
    @NSManaged public var desc: String?
    @NSManaged public var violation: ViolationEntity?
    @NSManaged public var lesson: LessonEntity?
    @NSManaged public var inspection: InspectionEntity?
    @NSManaged public var incident: IncidentEntity?
    @NSManaged public var toolBox: ToolBoxEntity?
    @NSManaged public var preTask: PreTaskEntity?
    @NSManaged public var observation: ObservationEntity?
}
