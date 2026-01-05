//
//  GenericRequest.swift
// ALNASR
//
//  Created by Developer on 14/09/21.
//

import Foundation

enum CommonRequest {
    case forgotPassword(email: ForgotPasswordRequest.Params)
    case changePassword(params: ChangePasswordRequest.Params)
}

extension CommonRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        nil
    }
    
    var endpoint: String {
        switch self {
        case .forgotPassword(_):
            return "forgot-password"
        case .changePassword(_):
            return "change-password"
        }
    }
    
    var params: Encodable? {
        switch self {
        case .forgotPassword(let params):
            return params
        case .changePassword(let params):
            return params
        }
    }
    
    
}
