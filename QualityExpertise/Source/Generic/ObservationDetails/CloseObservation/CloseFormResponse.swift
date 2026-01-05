//
//  CloseFormResponse.swift
// QualityExpertise
//
//  Created by developer on 02/03/22.
//

import Foundation

struct CloseFormResponse: Decodable {
    var observationId: Int
    var title: String
    var description: String
    var group: GroupDetail?
    var imageDescription: [ImageData]?
    var groupSpecified: Bool?
}
