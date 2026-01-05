//
//  ObservationDetailRequest.swift
// ALNASR
//
//  Created by developer on 23/02/22.
//

import Foundation

struct ObservationDetailRequest {
    struct Params: Encodable {
        var notificationId: Int
        var observationId: Int
    }
    
    struct CommonParams: Encodable {
        var observationId: Int
    }
    
    struct DeleteResponse: Decodable {
        var statusMessage: String
    }
    
    struct GeneratePDFResponse: Decodable {
        var pdfUrl: String
    }
    
    struct GuestObservationDetailsParams: Encodable {
        var guestUserId: Int
        var observationId: Int
    }
    
    struct GuestCommonParams: Encodable {
        var guestUserId: Int
        var observationId: Int
    }
}
