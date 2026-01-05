//
//  GroupRequest.swift
// QualityExpertise
//
//  Created by developer on 26/01/22.
//

import Foundation

import Foundation

enum GroupRequest {
    case createGroup(params: CreateGroupRequest.Params)
    case inviteGroup(params: InviteGroupRequest.Params)
    case groupList(params: GroupListRequest.params)
    case viewGroup(params: RequestAccessRequest.ViewGroupParams)
    case requestToGroup(params: RequestAccessRequest.Params)
    case userList(params: UserListRequest.Params)
    case details(params: GroupDetailRequest.DetailParms)
    case memberProfile(params: GroupMemberDetailsRequest.Params)
    case deleteMemberFromGroup(params: GroupDetailRequest.DeleteUserFromListParams)
    case changeUserRole(params: GroupDetailRequest.ChangeUserRoleParams)
    case handOverSuperAdminRights(params: GroupDetailRequest.HandOverSuperAdminRightsParams)
    case deleteGroup(params: GroupDetailRequest.GroupDeleteParams)
    case exitGroup(params: GroupDetailRequest.ExitGroupParams)
}

extension GroupRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .group
    }

    var endpoint: String {
        switch self {
        case .createGroup(_):
            return "create"
        case .inviteGroup(_):
            return "invite-users"
        case .groupList(_):
            return "list"
        case .viewGroup(_):
            return "view"
        case .requestToGroup(_):
            return "request-access"
        case .userList:
            return "user-list"
        case .details(_):
            return "details"
        case .memberProfile(_):
            return "member-profile"
        case .deleteMemberFromGroup(_):
            return "remove-member"
        case .changeUserRole(_):
            return "role-change"
        case .handOverSuperAdminRights(_):
            return "handover/superadmin-rights"
        case .deleteGroup(_):
            return "delete"
        case .exitGroup(_):
            return "exit"
        }
    }
    
    var params: Encodable? {
        switch self {
        case .createGroup(let params):
            return params
        case .inviteGroup(let params):
            return params
        case .groupList(let params):
            return params
        case .viewGroup(let params):
            return params
        case .requestToGroup(let params):
            return params
        case .userList(let params):
            return params
        case .details(let params):
            return params
        case .memberProfile(let params):
            return params
        case .deleteMemberFromGroup(let params):
            return params
        case .changeUserRole(let params):
            return params
        case .handOverSuperAdminRights(let params):
            return params
        case .deleteGroup(let params):
            return params
        case .exitGroup(let params):
            return params
        }
    }
}
