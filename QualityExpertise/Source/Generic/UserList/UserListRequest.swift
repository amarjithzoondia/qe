//
//  UserListRequest.swift
// QualityExpertise
//
//  Created by developer on 08/02/22.
//

import Foundation

struct UserListRequest {
    struct Params: Encodable {
        var groupId: Int
        var searchKey: String
        var groupCode: String
    }
    
    struct Response: Decodable {
        var users: [UserData]
    }
}
