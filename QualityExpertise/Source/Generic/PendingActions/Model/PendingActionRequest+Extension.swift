//
//  PendingActionRequest+Extension.swift
// QualityExpertise
//
//  Created by developer on 02/03/22.
//

import Foundation

extension PendingActionRequest {
    struct ListResponse: Decodable {
        var pendingActions: [PendingActionDetails]
        var notificationUnReadCount: Int
        var pendingActionsCount: Int
    }
    
    struct ChangeResponsiblePerson: Encodable {
        var observationId: Int
        var justification: String
        var responsiblePerson: Int
    }
    
    struct DeleteRequest: Encodable {
        var observationId: Int
        var justification: String
    }
    
    struct ActionRequest: Encodable {
        var id: Int
        var action: ActionType
    }
    
    struct ActionResponse: Decodable {
        var id: Int
        var isSuccess: Bool
        var statusMessage: String
    }
}
