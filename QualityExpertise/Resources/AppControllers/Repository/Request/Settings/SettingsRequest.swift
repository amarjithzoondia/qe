//
//  SettingsRequest.swift
// QualityExpertise
//
//  Created by developer on 18/02/22.
//

import Foundation

enum SettingsRequest {
    case settings(params: SettingsParams)
}

extension SettingsRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .settings
    }

    var endpoint: String {
        switch self {
        case .settings(_):
            return "update-notification"
        }
    }
    
    var params: Encodable? {
        switch self {
        case .settings(let params):
            return params
        }
    }
}
