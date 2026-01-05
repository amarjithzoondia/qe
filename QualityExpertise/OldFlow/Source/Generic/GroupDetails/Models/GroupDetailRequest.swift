//
//  GroupDetailRequest.swift
// ALNASR
//
//  Created by developer on 21/02/22.
//

import Foundation

struct GroupDetailRequest {
    struct DetailParms: Encodable {
        var notificationId: Int
        var groupId: Int
        var groupCode: String
    }
    
    struct DeleteUserFromListParams: Encodable {
        var groupId: Int
        var groupCode: String
        var userId: Int
    }
    
    struct DeleteUserFromListResponse: Decodable {
        var isSuccess: Bool
        var statusMessage: String
        var userId: Int
    }
    
    struct ChangeUserRoleParams: Encodable {
        var groupId: Int
        var groupCode: String
        var userId: Int
        var newRole: UserRole
    }
    
    struct ChangeUserRoleResponse: Decodable {
        var isSuccess: Bool
        var statusMessage: String
        var userId: Int
    }
    
    struct HandOverSuperAdminRightsParams: Encodable {
        var groupId: Int
        var groupCode: String
        var password: String
        var handOverTo: Int
    }
    
    struct CommonStatusResponse: Decodable {
        var isSuccess: Bool
        var statusMessage: String
    }
    
    struct GroupDeleteParams: Encodable {
        var groupId: Int
        var groupCode: String
        var password: String
    }
    
    struct ExitGroupParams: Encodable {
        var groupCode: String
    }
    
    struct ExitGroupResponse: Decodable {
        var statusMessage: String
    }
}
