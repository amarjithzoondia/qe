//
//  ContactUsRequest.swift
// QualityExpertise
//
//  Created by developer on 09/02/22.
//

import Foundation

enum ContactUsRequest {
    case contactUs
    case sendMessage(params: ContactUsInfo.SendMessageParams)
}

extension ContactUsRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .contact
    }
    
    var version: RespositoryVersion? {
        switch self {
        case .contactUs:
            return .v1
        default:
            return nil
        }
    }

    var endpoint: String {
        switch self {
        case .contactUs:
            return "info"
        case .sendMessage(_):
            return "send-message"
        }
    }
    
    var params: Encodable? {
        switch self {
        case .contactUs:
            return nil
        case .sendMessage(let params):
            return params
        }
    }
}
