//
//  EditProfileRequest.swift
// QualityExpertise
//
//  Created by developer on 09/02/22.
//

import Foundation

struct EditProfileRequest {
    struct Params: Encodable {
        var name: String
        var profileImage: String
        var company: String
        var designation: String
    }
}
