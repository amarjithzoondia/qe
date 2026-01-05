//
//  Untitled.swift
//  ALNASR
//
//  Created by Amarjith B on 04/06/25.
//

enum StaticEquipmentsRequest {
    case list(params: EquipmentListParams)
    case add(params: EquipmentStaticParams)
}

extension StaticEquipmentsRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .equipments
    }
    
    var endpoint: String {
        switch self {
        case .list:
            return "list"
        case .add:
            return "add"
        }
    }
    
    var params: (any Encodable)? {
        switch self {
        case .list(params: let params):
            return params
        case .add(params: let params):
            return params
        }
    }
    
    
}
