//
//  NFPendingActionDetails.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

struct NFPendingActionDetails: Decodable, Equatable {
    var id: Int
    var type: NFPendingActionType
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

extension NFPendingActionDetails {
    static func dummy(id: Int) -> NFPendingActionDetails {
        return NFPendingActionDetails(id: id, type: .openObservation, contentId: -1, date: "", description: "", groupCode: "", userId: -1, justification: "", isEditable: false, isMember: false)
    }
}
