//
//  UserDetails.swift
// QualityExpertise
//
//  Created by developer on 18/01/22.
//

import Foundation

struct UserDetails: Codable {
    var notificationUnReadCount: Int
    var pendingActionsCount: Int
    var companyLogo: String?
    var companyName: String?
}
