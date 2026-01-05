//
//  CloseObservationRequest.swift
// ALNASR
//
//  Created by developer on 24/02/22.
//

import Foundation

struct CloseObservationRequest {
    struct Params: Encodable {
        var observationId: Int
        var description: String
        var imageDescription: [ImageData]?
    }
    
    struct Response: Decodable {
        var statusMessage: String
    }
    
    struct GuestCloseParams: Encodable {
        var guestUserId: Int
        var observationId: Int
        var description: String
        var imageDescription: [ImageData]?
    }
}
