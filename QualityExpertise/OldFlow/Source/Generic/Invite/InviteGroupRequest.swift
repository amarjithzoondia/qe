//
//  InviteGroupRequest.swift
// ALNASR
//
//  Created by developer on 27/01/22.
//

import Foundation

struct InviteGroupRequest {
    struct Params: Encodable {
        var groupId: Int
        var groupCode: String
        var usersEmails: [String]
    }
    
    struct Response: Decodable {
        var isSuccess: Bool
    }
}
