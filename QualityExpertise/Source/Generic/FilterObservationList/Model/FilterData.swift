//
//  FilterData.swift
// QualityExpertise
//
//  Created by developer on 28/02/22.
//

import Foundation

struct FilterData {
    var status: Observation.Status
    var groupIds: [Int]
    var observers: [Int]
    var responsiblePersons: [Int]
    var openDate: String
    var closeDate: String
    var groupSpecified: Int
}
