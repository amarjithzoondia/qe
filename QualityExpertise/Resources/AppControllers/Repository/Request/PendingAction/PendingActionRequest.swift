//
//  PendingActionRequest.swift
// QualityExpertise
//
//  Created by developer on 02/03/22.
//

import Foundation

enum PendingActionRequest {
    case list
    case action(params: PendingActionRequest.ActionRequest)
}

extension PendingActionRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .pendingAction
    }
    
    var version: RespositoryVersion? {
        switch self {
        case .list:
            return .v1
        default:
            return nil
        }
    }

    var endpoint: String {
        switch self {
        case .list:
            return "list"
        case .action(_):
            return "action"
        }
    }
    
    var params: Encodable? {
        switch self {
        case .list:
            return nil
        case .action(let params):
            return params
        }
    }
}

