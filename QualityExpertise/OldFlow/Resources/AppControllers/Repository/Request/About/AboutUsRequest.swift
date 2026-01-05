//
//  AboutUsRequest.swift
// ALNASR
//
//  Created by developer on 09/02/22.
//

import Foundation

enum AboutUsRequest {
    case aboutUs
}

extension AboutUsRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .about
    }
    
    var version: RespositoryVersion? {
        switch self {
        case .aboutUs:
            return .v1
        }
    }

    var endpoint: String {
        switch self {
        case .aboutUs:
            return "info"
        }
    }
    
    var params: Encodable? {
        switch self {
        case .aboutUs:
            return nil
        }
    }
}
