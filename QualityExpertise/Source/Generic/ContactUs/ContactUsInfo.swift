//
//  ContactUsRequest.swift
// QualityExpertise
//
//  Created by developer on 09/02/22.
//

import Foundation

struct ContactUsInfo {
    struct Response: Decodable {
        var email: String
        var phone: String
        var address: String
    }
    
    struct SendMessageParams: Encodable {
        var name: String
        var email: String
        var message: String
    }
    
    struct SendMessageResponse: Decodable {
        var isSuccess: Bool
        var statusMessage: String
    }
}
