//
//  FilterRequest.swift
//  QualityExpertise
//
//  Created by Amarjith B on 21/10/25.
//

import Foundation

enum FilterRequest {
    case getContents
}

extension FilterRequest: RequestProtocol {
    
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        nil
    }
    
    var endpoint: String {
        switch self {
        case .getContents:
            return "filter-content"
        }
    }
    
    var params: Encodable? {
        switch self {
        case .getContents:
            return nil
        }
    }
}
