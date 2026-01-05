//
//  CloseDetails.swift
// ALNASR
//
//  Created by developer on 23/02/22.
//

import Foundation

struct CloseDetails: Decodable {
    var date: String?
    var time: String?
    var closeDescription: String?
    var imageDescription: [ImageData]?
    var closedBy: ClosedBy?
}

struct ClosedBy: Decodable {
    var userId: Int
    var image: String
    var name: String
    var email: String
}
