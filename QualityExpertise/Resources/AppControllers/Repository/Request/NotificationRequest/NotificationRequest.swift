//
//  NotificationRequest.swift
// QualityExpertise
//
//  Created by developer on 07/03/22.
//

import Foundation

enum NotificationRequest {
    case list
}

extension NotificationRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .notification
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

