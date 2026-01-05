//
//  NFGroupRequest.swift
//  QualityExpertise
//
//  Created by Amarjith B on 11/06/25.
//

import Foundation

enum NFGroupRequest {
    case groupList(params: NFGroupListParams)
    case details(params: GroupDetailRequest.DetailParms)
    case createGroup(params: CreateGroupRequest.Params)
    case inviteGroup(params: InviteGroupRequest.Params)
    case handOverSuperAdminRights(params: GroupDetailRequest.HandOverSuperAdminRightsParams)
    case changeUserRole(params: GroupDetailRequest.ChangeUserRoleParams)
    case userList(params: UserListRequest.Params)
    case requestToGroup(params: RequestAccessRequest.Params)
    case adminsOnlyList(params: AdminsListParams)
    case viewGroup(params: RequestAccessRequest.ViewGroupParams)
}

extension NFGroupRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var version: RespositoryVersion? {
        return .v3
    }
    
    
    var folderPath: RequestFolder? {
        .group
    }

    var endpoint: String {
        switch self {
        case .groupList(_):
            return "list"
        case .details(_):
            return "details"
        case .createGroup(_):
            return "create"
        case .inviteGroup(_):
            return "invite-users"
        case .handOverSuperAdminRights(_):
            return "handover/admin-rights"
        case .changeUserRole(_):
            return "role-change"
        case .userList(_):
            return "user-list"
        case .requestToGroup:
            return "request-access"
        case .adminsOnlyList:
            return "admins-only-list"
        case .viewGroup:
            return "view"
        }
    }
    
    var params: Encodable? {
        switch self {
        case .groupList(let params):
            return params
        case .details(let params):
            return params
        case .createGroup(let params):
            return params
        case .inviteGroup(let params):
            return params
        case .handOverSuperAdminRights(let params):
            return params
        case .changeUserRole(let params):
            return params
        case .userList(let params):
            return params
        case .requestToGroup(let params):
            return params
        case .adminsOnlyList(let params):
            return params
        case .viewGroup(let params):
            return params
        }
    }
}
