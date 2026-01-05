//
//  ViolationsRequest.swift
//  ALNASR
//
//  Created by Amarjith B on 21/07/25.
//

enum ViolationsRequest {
    case violationsList(params: ViolationListParams)
    case violationsDeatil(params: ViolationDetailParams)
    case addViolations(params: ViolationParams)
    case generatePdf(params: ViolationPdfParams)
    case generateExcel(params: ViolationExcelParams)
}

extension ViolationsRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .violations
    }
    
    var endpoint: String {
        switch self {
        case .violationsList:
            return "list"
        case.violationsDeatil:
            return "detail"
        case .addViolations:
            return "create"
        case .generatePdf:
            return "generate-pdf"
        case .generateExcel:
            return "generate-excel"
        }
    }
    
    var method: HttpMethod {
        return .post
    }
    
    var params: (any Encodable)? {
        switch self {
        case .violationsList(let params):
            return params
        case .violationsDeatil(params: let params):
            return params
        case .addViolations(params: let params):
            return params
        case .generatePdf(params: let params):
            return params
        case .generateExcel(params: let params):
            return params
        }
    }
    
    
}
