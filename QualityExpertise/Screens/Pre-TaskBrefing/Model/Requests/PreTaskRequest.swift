//
//  PreTaskRequest.swift
//  ALNASR
//
//  Created by Amarjith B on 27/10/25.
//

enum PreTaskRequest {
    case contents(params: PreTaskContentsParams)
    case detail(params: PreTaskDetailParams)
    case create(params: PreTaskParams)
    case list(params: PreTaskListParams)
    case generateExcel(params: PreTaskExcelParams)
    case generatePdf(params: PreTaskPdfParams)
}

extension PreTaskRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .preTask
    }
    
    var endpoint: String {
        switch self {
        case .contents:
            return "content-items"
        case .detail:
            return "detail"
        case .create:
            return "create"
        case .list:
            return "list"
        case .generateExcel:
            return "generate-excel"
        case .generatePdf:
            return "generate-pdf"
        }
    }
    
    var method: HttpMethod {
        return .post
    }
    
    var params: (any Encodable)? {
        switch self {
        case .contents(let params):
            return params
        case .detail(let params):
            return params
        case .create(let params):
            return params
        case .list(let params):
            return params
        case .generateExcel(let params):
            return params
        case .generatePdf(let params):
            return params
        }
    }
    
    
}
