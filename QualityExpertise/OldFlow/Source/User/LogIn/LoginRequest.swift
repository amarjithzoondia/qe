//
//  LoginRequest.swift
// ALNASR
//
//  Created by developer on 19/01/22.
//

import Foundation
import SwiftUI

struct LoginRequest {
    struct Params: Encodable {
        let email: String
        let password: String
    }
    
    struct Response: Decodable {
        let user: User
        let auth: Auth
        let userDetails: UserDetails
        let settings: SettingsModel
    }
}
