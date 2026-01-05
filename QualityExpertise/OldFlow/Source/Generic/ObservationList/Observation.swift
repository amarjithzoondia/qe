//
//  Observation.swift
// ALNASR
//
//  Created by developer on 10/02/22.
//

import Foundation

struct Observation: Decodable, Equatable {
    
    static func == (lhs: Observation, rhs: Observation) -> Bool {
        lhs.observationId == rhs.observationId
    }
    
    var observationId: Int
    var observationTitle: String
    var date: String
    var time: String
    var description: String
    var status: Status
    var group: GroupData?
    var images: [String]
    var totalImages: Int
}

extension Observation {
    static func dummy(observationId: Int) -> Observation {
        return Observation(observationId: -1, observationTitle: "", date: "", time: "", description: "", status: Status.allObservations, group: nil, images: [], totalImages: -1)
    }
}
