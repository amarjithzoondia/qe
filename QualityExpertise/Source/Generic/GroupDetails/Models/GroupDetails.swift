//
//  GroupDetails.swift
// QualityExpertise
//
//  Created by developer on 21/02/22.
//

import Foundation


struct GroupDetails: Decodable {
    var groupId: String
    var groupCode: String
    var groupImage: String
    var groupName: String
    var description: String
    var userRole: UserRole
    var members: [GroupMemberDetails]
    var notificationUnReadCount: Int
    var pendingActionsCount: Int
    var isAdmin: Bool?
}
