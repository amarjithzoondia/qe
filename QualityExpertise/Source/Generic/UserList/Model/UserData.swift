//
//  UserData.swift
// QualityExpertise
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
    
    enum CodingKeys: String, CodingKey {
        case userId, image, name, email, role, isSelected
    }
    
    init(userId: Int, image: String, name: String, email: String, role: UserRole? = nil, isSelected: Bool? = nil) {
        self.userId = userId
        self.image = image
        self.name = name
        self.email = email
        self.role = role
        self.isSelected = isSelected
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode userId safely from Int or String
        if let id = try? container.decode(Int.self, forKey: .userId) {
            self.userId = id
        } else if let idString = try? container.decode(String.self, forKey: .userId),
                  let id = Int(idString) {
            self.userId = id
        } else {
            self.userId = 0 // fallback/default
        }
        
        self.image = (try? container.decode(String.self, forKey: .image)) ?? ""
        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decode(String.self, forKey: .email)
        self.role = try? container.decode(UserRole.self, forKey: .role)
        self.isSelected = try? container.decode(Bool.self, forKey: .isSelected)
    }
}


extension UserData {
    static func dummy() -> UserData {
        return UserData(userId: -1, image: "", name: "", email: "", role: UserRole.participant, isSelected: false)
    }
}
