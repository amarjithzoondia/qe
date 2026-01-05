//
//  UpdateRequest.swift
// QualityExpertise
//
//  Created by developer on 21/02/22.
//

import Foundation

enum UpdateRequest {
    case updateComapnyDetails(params: CompanyDetailsParams)
}

extension UpdateRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .update
    }

    var endpoint: String {
        switch self {
        case .updateComapnyDetails(_):
            return "company-details"
        }
    }
    
    var params: Encodable? {
        switch self {
        case .updateComapnyDetails(let params):
            return params
        }
    }
}
