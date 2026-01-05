//
//  ChangePasswordRequest.swift
// QualityExpertise
//
//  Created by developer on 09/02/22.
//

import Foundation

struct ChangePasswordRequest {
    struct Params: Encodable {
        let oldPassword: String
        let newPassword: String
    }
    
    struct Response: Decodable {
        var isSuccess: Bool
        var statusmessage: String
    }
}
