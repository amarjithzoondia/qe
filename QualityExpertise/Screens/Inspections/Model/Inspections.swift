//
//  Inspections.swift
//  ALNASR
//
//  Created by Amarjith B on 03/06/25.
//

import Foundation

struct Inspections: Identifiable, Decodable {
    var id: Int
    var auditItem: AuditsInspectionsList
    var modelNumber: String?
    var inspectedBy: String
    var location: String
    var inspectionDate: String?
    var description: String
    var equipmentSource: EquipmentSource?
    var subContractor: String?
    var notes: String
    var createdAt: String
    var facilities: GroupData?
    var images: [ImageData]?
    var staticEquipment: [EquipmentStatic]?
    var lastQuestionsUpdatedAt: String?
    var formUpdatedTime: String?
//    var formVersion: String?
    
    static func dummy(id: Int = -1) -> Inspections {
        return Inspections(id: id, auditItem: .dummy(), modelNumber: "", inspectedBy: "", location: "", description: "", equipmentSource: .alnasar, subContractor: "", notes: "", createdAt: "", staticEquipment: [.dummy()])
    }
}


