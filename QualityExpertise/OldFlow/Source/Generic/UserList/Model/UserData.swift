//
//  UserData.swift
// ALNASR
//
//  Created by developer on 08/02/22.
//

import Foundation

struct UserData: Codable, Equatable {
    
    static func == (lhs: UserData, rhs: UserData) -> Bool {
        lhs.userId == rhs.userId
    }
    
    var userId: Int
    var image: String
    var name: String
    var email: String
    var role: UserRole?
    var isSelected: Bool?
}

extension UserData {
    static func dummy() -> UserData {
        return UserData(userId: -1, image: "", name: "", email: "", role: UserRole.participant, isSelected: false)
    }
}
