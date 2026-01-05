//
//  GroupMemberDetails.swift
// ALNASR
//
//  Created by developer on 21/02/22.
//

import Foundation

struct GroupMemberDetails: Decodable, Equatable {
    var userId: Int
    var image: String?
    var name: String
    var email: String
    var role: UserRole
}
