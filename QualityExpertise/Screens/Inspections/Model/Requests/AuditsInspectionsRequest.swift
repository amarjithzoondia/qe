//
//  AuditsInspectionsRequest.swift
//  ALNASR
//
//  Created by Amarjith B on 04/06/25.
//

enum AuditsInspectionsRequest {
    case list
}

extension AuditsInspectionsRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .inspections
    }
    
    var endpoint: String {
        switch self {
        case .list:
            return "audit-items"
        }
    }
    
    var params: (any Encodable)? {
        switch self {
        case .list:
            return nil
        }
    }
    
    
}
