//
//  GroupData.swift
// ALNASR
//
//  Created by developer on 28/01/22.
//

import SwiftUI

struct GroupData: Codable, Equatable {
    
    static func == (lhs: GroupData, rhs: GroupData) -> Bool {
        lhs.groupId == rhs.groupId
    }
    
    var groupId: String
    var groupCode: String
    var groupName: String
    var groupImage: String
    var userRole: UserRole?
    var isSelected: Bool?
    var description: String?
}

extension GroupData {
    static func dummy() -> GroupData {
        return GroupData(groupId: "", groupCode: "", groupName: "", groupImage: "", userRole: UserRole.participant, isSelected: false)
    }
}
