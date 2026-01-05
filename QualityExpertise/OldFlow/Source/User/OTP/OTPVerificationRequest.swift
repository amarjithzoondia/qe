//
//  OTPVerificationRequest.swift
// ALNASR
//
//  Created by developer on 20/01/22.
//

import Foundation

struct OTPVerificationRequest {
    struct Params: Encodable {
        var tempUserId: Int
        var email: String
        var otp: String
    }
    
    struct Response: Decodable {
        var otpVerified: Bool
        var uuid: String
        var user: User?
        var settings: SettingsModel?
        var auth: Auth?
    }
}

struct EmailRequestData {
    struct Params: Encodable {
        var tempUserId: Int
        var email: String
        var otpType: OTPType
        var userId: Int
    }
    
    struct Response: Decodable {
        var statusMessage: String
    }
}

enum OTPType: Int, Encodable {
    case registration = 1
    case delete = 2
}
