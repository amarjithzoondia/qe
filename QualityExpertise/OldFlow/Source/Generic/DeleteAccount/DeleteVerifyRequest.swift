//
//  DeleteVerifyRequest.swift
// ALNASR
//
//  Created by Developer on 21/07/22.
//

import Foundation

struct DeleteVerifyRequestParam: Encodable {
    let otp: String
    let refresh: String
}

struct DeleteVerifyRequestResponse: Decodable {
    let title: String
    let description: String
}
