//
//  CreateGroupRequest.swift
// ALNASR
//
//  Created by developer on 26/01/22.
//

import Foundation

struct CreateGroupRequest {
    struct Params: Encodable {
        var groupCode: String?
        var groupName: String
        var description: String
        var groupImage: String

    }
}
