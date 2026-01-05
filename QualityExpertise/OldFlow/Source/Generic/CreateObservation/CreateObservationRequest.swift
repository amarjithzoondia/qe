//
//  CreateObservationRequest.swift
// ALNASR
//
//  Created by developer on 09/02/22.
//

import Foundation

struct CreateObservationRequest {
    
    struct Params: Encodable {
        var observationId: Int
        var observationTitle: String
        var reportedBy: String
        var location: String
        var description: String
        var groupSpecified: Int
        var groupId: Int
        var notificationTo: [Int]
        var responsiblePersonName: String
        var responsiblePerson: Int
        var imageDescription: [ImageData]
        var saveAsDraft: Bool
        var responsiblePersonEmail: String
        var customResponsiblePerson: CustomResponsiblePerson
    }
    
    struct Response: Decodable {
        var observationId: Int
        var statusMessage: String
    }
    
    struct GuestParams: Encodable {
        var guestUserId: Int
        var observationTitle: String
        var reportedBy: String
        var location: String
        var description: String
        var responsiblePerson: String
        var imageDescription: [ImageData]
        var responsiblePersonEmail: String
    }
}
