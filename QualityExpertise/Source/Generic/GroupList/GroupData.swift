//
//  GroupData.swift
// QualityExpertise
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
    var isAdmin: Bool?
}

extension GroupData {
    static func dummy() -> GroupData {
        return GroupData(groupId: "4567", groupCode: "OXPZ-67121", groupName: "Testing Group", groupImage: "https://png.pngtree.com/element_our/png/20181213/nipplebabydummypacifierkids-white-glyph-icon-in-circle-png_267962.jpg", userRole: UserRole.participant, isSelected: false)
    }
}
