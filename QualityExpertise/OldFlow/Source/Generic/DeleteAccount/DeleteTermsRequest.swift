//
//  DeleteTermsRequest.swift
// ALNASR
//
//  Created by Developer on 21/07/22.
//

import Foundation

struct DeleteTermsParams: Encodable {
    let isGuestUser: Bool
}

struct DeleteTermsRequest: Decodable {
    let content: String
}
