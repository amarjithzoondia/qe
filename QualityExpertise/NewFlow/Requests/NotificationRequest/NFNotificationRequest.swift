//
//  NFNotificationRequest.swift
//  QualityExpertise
//
//  Created by Amarjith B on 13/06/25.
//

import Foundation

enum NFNotificationRequest {
    case list
}

extension NFNotificationRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .notification
    }
    
    var version: RespositoryVersion? {
        .v3
    }

    var endpoint: String {
        switch self {
        case .list:
            return "list"
        }
    }
    
    var params: Encodable? {
        switch self {
        case .list:
            return nil
        }
    }
}

