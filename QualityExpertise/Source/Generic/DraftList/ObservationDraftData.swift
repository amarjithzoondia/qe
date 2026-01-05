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

struct NFObservationDraftData: Codable, Equatable, Identifiable {
    static func == (lhs: NFObservationDraftData, rhs: NFObservationDraftData) -> Bool {
        lhs.id == rhs.id
    }
    var id: Int
    var observationTitle: String
    var reportedBy: String
    var location: String?
    var description: String?
    var responsiblePersonName: String?
    var responsiblePersonEmail: String?
    var projectResponsiblePerson: UserData?
    var sendNotification: [UserData]?
    var imageDescription: [ImageData]?
    var facilites: GroupData?
    var createdAt: String
}

extension NFObservationDraftData {
    static let empty = NFObservationDraftData(
        id: -1,
        observationTitle: "",
        reportedBy: "",
        location: nil,
        description: nil,
        responsiblePersonName: nil,
        responsiblePersonEmail: nil,
        projectResponsiblePerson: nil,
        sendNotification: nil,
        imageDescription: nil,
        facilites: nil,
        createdAt: ""
    )
}
