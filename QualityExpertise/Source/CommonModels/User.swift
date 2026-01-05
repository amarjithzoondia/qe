//
//  User.swift
// QualityExpertise
//
//  Created by Apple on 18/01/22.
//

import Foundation

class User: Codable, Identifiable, ObservableObject {
    
    var uuid: String?
    var userId: Int
    var name: String
    var email: String
    var profileImage: String?
    var designation: String?
    var company: String?
    var userType: UserType?
    
    init(uuid: String?, userId: Int, name: String, email: String, profileImage: String? = nil, designation: String? = nil, company: String? = nil, userType: UserType? = .normalUser) {
        self.uuid = uuid
        self.userId = userId
        self.name = name
        self.email = email
        self.profileImage = profileImage
        self.designation = designation
        self.company = company
        self.userType = userType
    }
}
