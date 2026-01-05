//
//  UserRequest.swift
// QualityExpertise
//
//  Created by Developer on 24/08/21.
//

import Foundation

enum UserRequest {
    case login(params: LoginRequest.Params)
    case register(params: RegisterRequest.Params)
    case emailVerify(params: OTPVerificationRequest.Params)
    case logOut
    case editProfile(params: EditProfileRequest.Params)
    case userList(params: UserListForGroupRequest.Params)
    case delete(params: DeleteUserRequestParam)
    case deleteVerify(params: DeleteVerifyRequestParam)
    case deleteTerms(params: DeleteTermsParams)
}

extension UserRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .user
    }

    var endpoint: String {
        switch self {
        case .login(_):
            return "login"
        case .register(_):
            return "registration"
        case .emailVerify(_):
            return "email-verify"
        case .logOut:
            return "logout"
        case .editProfile(_):
            return "profile/edit"
        case .userList(_):
            return "group-users-list"
        case .delete(_):
            return "delete"
        case .deleteVerify(_):
            return "delete-verify"
        case .deleteTerms(_):
            return "delete/terms"
        }
    }
    
    var params: Encodable? {
        switch self {
        case .login(let params):
            return params
        case .register(let params):
            return params
        case .emailVerify(let params):
            return params
        case .logOut:
            return nil
        case .editProfile(let params):
            return params
        case .userList(let params):
            return params
        case .delete(let params):
            return params
        case .deleteVerify(let params):
            return params
        case .deleteTerms(let params):
            return params
        }
    }
}
