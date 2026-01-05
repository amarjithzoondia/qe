//
//  RefreshTokenRequest.swift
// ALNASR
//
//  Created by developer on 09/02/22.
//

import Foundation

enum RefreshTokenRequest {
    case refreshToken(refresh: String)
}

extension RefreshTokenRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .token
    }

    var endpoint: String {
        switch self {
        case .refreshToken(_):
            return "refresh"
        }
    }
    
    var params: Encodable? {
        switch self {
        case .refreshToken(refresh: let refreshToken):
            return RefreshToken(refresh: refreshToken)
        }
    }
}

