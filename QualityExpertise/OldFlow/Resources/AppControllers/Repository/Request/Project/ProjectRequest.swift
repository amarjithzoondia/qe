//
//  ProjectRequest.swift
//  ALNASR
//
//  Created by Amarjith B on 09/04/25.
//

import Foundation

enum ProjectRequest {
    case list(params:ProjectListParams)
    case deatils(params:ProjectDetailParams)
}

extension ProjectRequest:RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .project
    }
    
    var endpoint: String {
        switch self {
        case .list:
            return "list"
        case.deatils:
            return "detail"
        }
    }
    
    var method: HttpMethod {
        switch self {
        case .list:
            return .get
        case .deatils:
            return .get
        }
    }
    
    var params: (any Encodable)? {
        switch self {
        case .list(let params):
            return params
        case .deatils(params: let params):
            return params
        }
    }
    
    
}
