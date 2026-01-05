//
//  GuestObservationDetails.swift
// QualityExpertise
//
//  Created by developer on 25/02/22.
//

import Foundation

struct GuestObservationDetails: Decodable {
    var observationTitle: String
    var status: Observation.Status
    var date: String
    var time: String
    var reportedBy: String
    var location: String?
    var description: String?
    var imageDescription: [ImageData]?
    var responsiblePerson: String
    var closeDetails: CloseDetails?
}

extension GuestObservationDetails {
    static func dummy(observationId: Int) -> GuestObservationDetails {
        return GuestObservationDetails(observationTitle: "", status: .openObservations, date: "", time: "", reportedBy: "", location: "", description: "", imageDescription: nil, responsiblePerson: "", closeDetails: nil)
    }
}
