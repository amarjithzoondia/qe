//
//  DeleteUserRequest.swift
// ALNASR
//
//  Created by Developer on 21/07/22.
//

import Foundation

struct DeleteUserRequestParam: Encodable {
    let password: String
}

struct DeleteUserRequestResponse: Decodable {
    let content: String
}
  
struct DeleteGuestUserParam: Encodable {
    let guestUserId: Int
}
