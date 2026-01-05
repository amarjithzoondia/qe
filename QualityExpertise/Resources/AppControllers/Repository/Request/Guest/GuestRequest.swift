//
//  GuestRequest.swift
// QualityExpertise
//
//  Created by developer on 10/02/22.
//

import Foundation

enum GuestRequest {
    case createObservation(params: CreateObservationRequest.GuestParams)
    case list(params: ObservationRequest.GusetListParams)
    case exportToExcel(params: ObservationRequest.GusetListParams)
    case updateComapnyDetails(params: GusetCompanyParams)
    case observationDetails(params: ObservationDetailRequest.GuestObservationDetailsParams)
    case closeObservation(params: CloseObservationRequest.GuestCloseParams)
    case generatePdf(params: ObservationDetailRequest.GuestCommonParams)
    case deleteObservation(params: ObservationDetailRequest.GuestCommonParams)
    case delete(param: DeleteGuestUserParam)
}

extension GuestRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .guest
    }
    
    var version: RespositoryVersion? {
        switch self {
        case .generatePdf(_):
            return .v2
        default:
            return nil
        }
    }

    var endpoint: String {
        switch self {
        case .list(_):
            return "observation/list"
        case .createObservation(_):
            return "observation/create"
        case .exportToExcel(_):
            return "observation/generate-excel"
        case .updateComapnyDetails(_):
            return "update/company-details"
        case .observationDetails(_):
            return "observation/detail"
        case .closeObservation(_):
            return "observation/close"
        case .generatePdf(_):
            return "observation/generate-pdf"
        case .deleteObservation(_):
            return "observation/delete"
        case .delete(_):
            return "user/delete"
        }
    }
    
    var params: Encodable? {
        switch self {
        case .list(let params):
            return params
        case .createObservation(let params):
            return params
        case .exportToExcel(let params):
            return params
        case .updateComapnyDetails(let params):
            return params
        case .observationDetails(let params):
            return params
        case .closeObservation(let params):
            return params
        case .generatePdf(let params):
            return params
        case .deleteObservation(let params):
            return params
        case .delete(let params):
            return params
        }
    }
}
