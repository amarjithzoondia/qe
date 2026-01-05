//
//  NFObservationsRequest.swift
//  QualityExpertise
//
//  Created by Amarjith B on 11/06/25.
//
import Foundation

enum NFObservationsRequest {
    case observationList(params: ObservationRequest.ListParams)
    case createObservation(params: CreateObservationRequest.Params)
    case exportToExcel(params: ObservationRequest.ListParams)
    case saveAsDraft(params: ObservationDraftData)
    case draftList
    case deleteDraft(params: DeleteDraftParams)
    case closeObservation(params: CloseObservationRequest.Params)
    case changeResponsiblePerson(params: PendingActionRequest.ChangeResponsiblePerson)
    case deleteRequest(params: PendingActionRequest.DeleteRequest)
}

extension NFObservationsRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var version: RespositoryVersion? {
        return .v3
    }
    
    var folderPath: RequestFolder? {
        return .observation
    }
    
    var endpoint: String {
        switch self {
        case .observationList:
            return "list"
        case .createObservation:
            return "create"
        case .exportToExcel:
            return "generate-excel"
        case .saveAsDraft:
            return "draft/create"
        case .draftList:
            return "draft-list"
        case .deleteDraft:
            return "draft/delete"
        case .closeObservation:
            return "close"
        case .changeResponsiblePerson:
            return "responsible-change"
        case .deleteRequest:
            return "delete-request"
        }
    }
    
    var params: (any Encodable)? {
        switch self {
        case .observationList(let params):
            return params
        case .createObservation(let params):
            return params
        case .exportToExcel(let params):
            return params
        case .saveAsDraft(let params):
            return params
        case .draftList:
            return nil
        case .deleteDraft(let params):
            return params
        case .closeObservation(let params):
            return params
        case .changeResponsiblePerson(let params):
            return params
        case .deleteRequest(let params):
            return params
        }
    }
    
    
}
