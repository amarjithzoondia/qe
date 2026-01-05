//
//  GenericRequest.swift
// ALNASR
//
//  Created by developer on 18/01/22.
//

import Foundation

enum GenericRequest {
    case splash(SpalshRequest.Params)
}

extension GenericRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .generic
    }

    var endpoint: String {
        switch self {
        case .splash(_):
            return "user-check"
        }
    }
    
    var params: Encodable? {
        switch self {
        case .splash(let params):
            return params
        }
    }
}
