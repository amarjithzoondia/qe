//
//  EmployeeRequest.swift
//  ALNASR
//
//  Created by Amarjith B on 15/09/25.
//

enum EmployeeRequest {
    case employeeList(params: EmployeeListParams)
    case allList
}

extension EmployeeRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .employees
    }
    
    var endpoint: String {
        switch self {
        case .employeeList:
            return "list"
        case .allList:
            return "all-list"
        }
    }
    
    var method: HttpMethod {
        return .post
    }
    
    var params: (any Encodable)? {
        switch self {
        case .employeeList(let params):
            return params
        case .allList:
            return nil
        }
    }
    
    
}
