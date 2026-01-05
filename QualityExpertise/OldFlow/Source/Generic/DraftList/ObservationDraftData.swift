//
//  ObservationDraftData.swift
// ALNASR
//
//  Created by developer on 16/02/22.
//

import Foundation

struct ObservationDraftData: Codable, Equatable, Identifiable {
    static func == (lhs: ObservationDraftData, rhs: ObservationDraftData) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: Int
    var observationTitle: String
    var reportedBy: String?
    var location: String?
    var description: String?
    var responsiblePersonName: String
    var imageDescription: [ImageData]
    var createdTime: String
    var updatedTime: String
}
