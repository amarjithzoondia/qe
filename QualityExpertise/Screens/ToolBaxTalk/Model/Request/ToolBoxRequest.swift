//
//  ToolBoxRequest.swift
//  QualityExpertise
//
//  Created by Amarjith B on 16/09/25.
//


enum ToolBoxRequest {
    case toolBoxList(params: ToolBoxListParams)
    case toolBoxDeatil(params: ToolBoxDetailParams)
    case addToolBox(params: ToolBoxParams)
    case generatePdf(params: ToolBoxPdfParams)
    case generateExcel(params: ToolBoxExcelParams)
}

extension ToolBoxRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .toolBoxTalk
    }
    
    var endpoint: String {
        switch self {
        case .toolBoxList:
            return "list"
        case.toolBoxDeatil:
            return "detail"
        case .addToolBox:
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
        case .toolBoxList(let params):
            return params
        case .toolBoxDeatil(params: let params):
            return params
        case .addToolBox(params: let params):
            return params
        case .generatePdf(params: let params):
            return params
        case .generateExcel(params: let params):
            return params
        }
    }
    
    
}
