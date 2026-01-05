//
//  RequestAccessRequest.swift
// QualityExpertise
//
//  Created by developer on 30/01/22.
//

import Foundation

struct RequestAccessRequest {
    struct ViewGroupParams: Encodable {
        var groupId: Int?
        var groupShortCode: String
        var notificationId: Int?
    }
    
    struct ViewGroupResponse: Decodable {
        var groupVerified: Bool
        var statusMessage: String
        var group: GroupData?
        var notificationUnReadCount: Int
        var pendingActionsCount: Int
    }
    
    struct Params: Encodable {
        var groupId: Int?
        var groupShortCode: String
    }
    
    struct Response: Decodable {
        var groupVerified: Bool
        var group: GroupData?
        var statusMessage: String
    }
}
