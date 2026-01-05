//
//  GeneralRequest.swift
// QualityExpertise
//
//  Created by developer on 18/02/22.
//

import Foundation

enum GeneralRequest {
    case staticContents(params: StaticContentParams)
}

extension GeneralRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .general
    }

    var endpoint: String {
        switch self {
        case .staticContents(_):
            return "contents"
        }
    }
    
    var params: Encodable? {
        switch self {
        case .staticContents(let params):
            return params
        }
    }
}

