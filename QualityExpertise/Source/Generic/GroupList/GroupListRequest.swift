//
//  GroupRequest.swift
// QualityExpertise
//
//  Created by developer on 27/01/22.
//

import Foundation

struct GroupListRequest {
    struct params: Encodable {
        var searchKey: String
    }
    
    struct Response: Decodable {
        var groups: [GroupData]
    }
}
