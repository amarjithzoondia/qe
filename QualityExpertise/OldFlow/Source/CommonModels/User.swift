//
//  User.swift
// ALNASR
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
    
    init(uuid: String?, userId: Int, name: String, email: String, profileImage: String? = nil, designation: String? = nil, company: String? = nil) {
        self.uuid = uuid
        self.userId = userId
        self.name = name
        self.email = email
        self.profileImage = profileImage
        self.designation = designation
        self.company = company
    }
}
