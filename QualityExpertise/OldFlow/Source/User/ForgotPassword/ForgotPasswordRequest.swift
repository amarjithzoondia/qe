//
//  ForgotPasswordRequest.swift
// ALNASR
//
//  Created by developer on 21/01/22.
//

import Foundation

struct ForgotPasswordRequest {
    struct Params: Encodable {
        var email: String
    }
    
    struct Response: Decodable {
        var message: String
    }
}
