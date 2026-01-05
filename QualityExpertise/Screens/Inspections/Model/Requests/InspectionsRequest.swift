//
//  InspectionsRequest.swift
//  ALNASR
//
//  Created by Amarjith B on 04/06/25.
//

enum InspectionsRequest {
    case inspectionList(params: InspectionsListParams)
    case inspectionDeatil(params: InspectionDetailParams)
    case addInspection(params: EquipmentStaticParams)
    case generatePdf(params: InspectionPdfParams)
    case generateExcel(params: InspectionExcelParams)
    case contents(params: InspectionContentsParams)
    case auditItems(params: InspectionAuditItemsParams)
}

extension InspectionsRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .inspections
    }
    
    var endpoint: String {
        switch self {
        case .inspectionList:
            return "list"
        case.inspectionDeatil:
            return "details"
        case .addInspection:
            return "add"
        case .generatePdf:
            return "generate-pdf"
        case .generateExcel:
            return "generate-excel"
        case .contents:
            return "contents-list"
        case .auditItems:
            return "audit-items"
        }
    }
    
    var method: HttpMethod {
        return .post
    }
    
    var params: (any Encodable)? {
        switch self {
        case .inspectionList(let params):
            return params
        case .inspectionDeatil(params: let params):
            return params
        case .addInspection(params: let params):
            return params
        case .generatePdf(params: let params):
            return params
        case .generateExcel(params: let params):
            return params
        case .contents(params: let params):
            return params
        case .auditItems(params: let params):
            return params
        }
    }
    
    
}
