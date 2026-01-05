//
//  StaticEquipmentParams.swift
//  ALNASR
//
//  Created by Amarjith B on 04/06/25.
//

struct EquipmentStaticParams: Codable {
    var auditItemId: Int
    var modelNumber: String?
    var inspectedBy: String
    var location: String
    var inspectionDate: String?
    var description: String
    var equipmentSource: EquipmentSource?
    var facilities: String?
    var subContractor: String
    var staticEquipment: [EquipmentStatic]
    var notes: String
    var images: [ImageData]
}

struct StaticEquipmentResponse: Codable {
    let inspectionId: Int
    let statusMessage: String
}

struct EquipmentListParams: Codable {
    let id: Int
}


