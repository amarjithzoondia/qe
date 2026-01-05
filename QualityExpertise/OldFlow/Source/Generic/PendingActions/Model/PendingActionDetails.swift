//
//  PendingActionDetail.swift
// ALNASR
//
//  Created by developer on 02/03/22.
//

import SwiftUI

struct PendingActionDetails: Decodable, Equatable {
    var id: Int
    var type: PendingActionType
    var contentId: Int
    var date: String
    var description: String
    var groupCode: String
    var userId: Int
    var justification: String?
    var isUserSpecific: Bool?
    var isEditable: Bool
    var isMember: Bool
}

extension PendingActionDetails {
    static func dummy(id: Int) -> PendingActionDetails {
        return PendingActionDetails(id: id, type: .openObservation, contentId: -1, date: "", description: "", groupCode: "", userId: -1, justification: "", isEditable: false, isMember: false)
    }
}
