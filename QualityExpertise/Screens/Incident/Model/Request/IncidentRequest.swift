//
//  IncidentRequest.swift
//  ALNASR
//
//  Created by Amarjith B on 10/09/25.
//

enum IncidentRequest {
    case incidentList(params: IncidentListParams)
    case incidentDeatil(params: IncidentDetailParams)
    case addIncident(params: IncidentParams)
    case generatePdf(params: IncidentPdfParams)
    case generateExcel(params: IncidentExcelParams)
}

extension IncidentRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .incident
    }
    
    var endpoint: String {
        switch self {
        case .incidentList:
            return "list"
        case.incidentDeatil:
            return "detail"
        case .addIncident:
            return "add"
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
        case .incidentList(let params):
            return params
        case .incidentDeatil(params: let params):
            return params
        case .addIncident(params: let params):
            return params
        case .generatePdf(params: let params):
            return params
        case .generateExcel(params: let params):
            return params
        }
    }
    
    
}
