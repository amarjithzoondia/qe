//
//  RegisterRequest.swift
// ALNASR
//
//  Created by developer on 20/01/22.
//

import Foundation

struct RegisterRequest {
    
    struct Params: Encodable {
        var uuid: String
        var name: String
        var email: String
        var profileImage: String?
        var designation: String?
        var company: String?
        var password: String?
    }
    
    struct Response: Decodable {
        let tempUserId: Int
        let email: String
    }
}
