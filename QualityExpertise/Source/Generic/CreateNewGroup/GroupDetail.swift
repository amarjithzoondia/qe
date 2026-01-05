//
//  GroupDetails.swift
// QualityExpertise
//
//  Created by developer on 27/01/22.
//

import SwiftUI

struct GroupDetail: Codable, Equatable {
    
    static func == (lhs: GroupDetail, rhs: GroupDetail) -> Bool {
        lhs.groupId == rhs.groupId
    }
    
    var groupId: Int
    var groupCode: String
    var groupName: String
    var description: String?
    var groupImage: String
    var userRole: UserRole?
    var isSelected: Bool?
    
}

extension GroupDetail {
    static func dummy() -> GroupDetail {
        return GroupDetail(groupId: -1, groupCode: "", groupName: "", description: "", groupImage: "", userRole: UserRole.participant, isSelected: false)
    }
}
