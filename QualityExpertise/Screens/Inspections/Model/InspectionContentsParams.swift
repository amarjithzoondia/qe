//
//  InspectionContentsParams.swift
//  ALNASR
//
//  Created by Amarjith B on 08/08/25.
//

struct InspectionContentsParams: Codable {
//    var formVersion: [FormVersionRequest]?
    var updatedTime: String?
}

struct InspectionContentsResponse: Codable {
    var contentsList: [EquipmentStaticResponse]
}
