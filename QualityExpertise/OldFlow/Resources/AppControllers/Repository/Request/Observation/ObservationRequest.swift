//
//  ObservationRequest.swift
// ALNASR
//
//  Created by developer on 09/02/22.
//

import Foundation

enum ObservationRequest {
    case createObservation(params: CreateObservationRequest.Params)
    case observationList(params: ListParams)
    case deleteObservation(params: ObservationDetailRequest.CommonParams)
    case generatePdf(params: ObservationDetailRequest.CommonParams)
    case changeResponsiblePerson(params: PendingActionRequest.ChangeResponsiblePerson)
    case deleteRequest(params: PendingActionRequest.DeleteRequest)
    case observationDetails(params: ObservationDetailRequest.Params)
    case closeObservation(params: CloseObservationRequest.Params)
    case exportToExcel(params: ObservationRequest.ListParams)
    case closeform(params: ObservationDetailRequest.CommonParams)
}

extension ObservationRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var version: RespositoryVersion? {
        switch self {
        case .observationList(_):
            return .v1
        case .observationDetails(_):
            return .v2
        case .closeObservation(_):
            return .v2
        case .createObservation(_):
            return .v2
        case .exportToExcel(_):
            return .v2
        case .closeform(_):
            return .v2
        case .generatePdf(_):
            return .v2
        default:
            return nil
        }
    }
    
    
    var folderPath: RequestFolder? {
        .observation
    }
    
    var endpoint: String {
        switch self {
        case .createObservation(_):
            return "create"
        case .observationList(_):
            return "list"
        case .deleteObservation(_):
            return "delete"
        case .generatePdf(_):
            return "generate-pdf"
        case .changeResponsiblePerson(_):
            return "responsible-change"
        case .deleteRequest(_):
            return "delete-request"
        case .observationDetails(_):
            return "detail"
        case .closeObservation(_):
            return "close"
        case .exportToExcel(_):
            return "generate-excel"
        case .closeform(_):
            return "close-form"
        }
    }
    
    var params: Encodable? {
        switch self {
        case .createObservation(let params):
            return params
        case .observationList(let params):
            return params
        case .deleteObservation(let params):
            return params
        case .generatePdf(let params):
            return params
        case .changeResponsiblePerson(let params):
            return params
        case .deleteRequest(let params):
            return params
        case .observationDetails(let params):
            return params
        case .closeObservation(let params):
            return params
        case .exportToExcel(let params):
            return params
        case .closeform(let params):
            return params
        }
    }
}
