//
//  EmailRequest.swift
// ALNASR
//
//  Created by developer on 20/01/22.
//

import Foundation

enum EmailRequest {
    case resendOtp(params: EmailRequestData.Params)
}

extension EmailRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .email
    }
    
    var version: RespositoryVersion? {
        switch self {
        case .resendOtp(_):
            return .v1
        }
    }

    var endpoint: String {
        switch self {
        case .resendOtp(_):
            return "resend-otp"
        }
    }
    
    var params: Encodable? {
        switch self {
        case .resendOtp(let params):
            return params
        }
    }
}
