//
//  ObservationDetails.swift
// ALNASR
//
//  Created by developer on 23/02/22.
//

import Foundation

struct ObservationDetails: Decodable {
    var observationTitle: String
    var status: Observation.Status
    var date: String
    var time: String
    var reportedBy: String
    var location: String?
    var description: String?
    var groupSpecified: Bool?
    var creatorId: Int?
    var responsiblePersonName: String?
    var isCancelable: Bool?
    var group: GroupData?
    var imageDescription: [ImageData]?
    var responsiblePerson: UserData?
    var saveAsDraft: Bool?
    var closeDetails: CloseDetails?
    var notificationUnReadCount: Int
    var pendingActionsCount: Int
}

extension ObservationDetails {
    static func dummy(observationId: Int) -> ObservationDetails {
        return ObservationDetails(observationTitle: "", status: Observation.Status.allObservations, date: "", time: "", reportedBy: "", location: "", description: "", groupSpecified: false, creatorId: -1, isCancelable: false, group: GroupData.dummy(), imageDescription: [ImageData.dummy(imageCount: 0)], responsiblePerson: UserData.dummy(), saveAsDraft: false, closeDetails: nil, notificationUnReadCount: -1, pendingActionsCount: -1)
    }
}
