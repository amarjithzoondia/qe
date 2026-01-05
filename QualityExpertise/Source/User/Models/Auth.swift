//
//  Auth.swift
// QualityExpertise
//
//  Created by developer on 18/01/22.
//

import Foundation

struct Auth: Codable {
    var access, refresh: String
    var tokenExpiry: Int
}
