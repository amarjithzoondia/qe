//
//  RoleRequest.swift
//  QualityExpertise
//
//  Created by Amarjith B on 12/06/25.
//

enum DashboardRequest {
    case dashBoardFlag(params: DashboardParam)
}

extension DashboardRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        nil
    }
    
    var version: RespositoryVersion? {
        return .v3
    }
    
    var endpoint: String {
        "dashboard-flags"
    }
    
    var params: (any Encodable)? {
        switch self {
        case .dashBoardFlag(let params):
            return params
        }
    }
    
    
}
