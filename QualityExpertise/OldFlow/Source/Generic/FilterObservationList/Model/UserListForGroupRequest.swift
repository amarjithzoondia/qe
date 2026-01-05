//
//  UserListRequest.swift
// ALNASR
//
//  Created by developer on 28/02/22.
//

import Foundation

struct UserListForGroupRequest {
    struct Params: Encodable {
        var searchKey: String
    }
    struct Response: Decodable {
        var users: [UserData]
    }
}
