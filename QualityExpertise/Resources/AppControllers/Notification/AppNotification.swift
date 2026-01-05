//
//  File.swift
// QualityExpertise
//
//  Created by developer on 16/03/22.
//

import Foundation

class AppNotification: Codable, Identifiable, ObservableObject {
    var id: Int?
    var type:Int?
    var contentId: Int?
    var title: String?
    var time: String?
    var date: String?
    var description: String?
    var groupCode: String?
    var isRead: Bool?
    var userId: Int?
    var justification: String?
    var pushType: PushType?
    
    var typeRaw: AppNotificationType? {
        if let type = type {
            return AppNotificationType(rawValue: type)
        }
        return nil
    }
    
    internal init(id: Int, type: Int, contentId: Int, title: String?, time: String?, date: String?, description: String?, groupCode: String?, isRead: Bool, pushType: PushType?) {
        self.id = id
        self.type = type
        self.contentId = contentId
        self.title = title
        self.time = time
        self.date = date
        self.description = description
        self.groupCode = groupCode
        self.isRead = isRead
        self.pushType = pushType
    }
}

enum AppNotificationType: Int {
    case joinGrouprequestAccepted = 1
    case joinGrouprequestRejected = 2
    case addedToGroup = 3
    case removeFromGroup = 4
    case deleteObservationRequestApproved = 5
    case deleteObservationRequestRejected = 6
    case observationDeleted = 7
    case reviewObservationCloseOutApproved = 8
    case reviewObservationCloseOutRejected = 9
    case reassignresponsiblePersonApproved = 10
    case reassignresponsiblePersonRejected = 11
    case groupMemberRoleChanged = 12
    case observationCreated = 13
    case general = 14
    case observationCreatedToResponsiblePerson = 15
    case observationClosedToResponsiblePerson = 16
    
    // newflow
    
    case joinGrouprequestAcceptedNF = 17
    case joinGrouprequestRejectedNF = 18
    case addedToGroupNF = 19
    case removeFromGroupNF = 20
    case deleteObservationRequestApprovedNF = 21
    case deleteObservationRequestRejectedNF = 22
    case observationDeletedNF = 23
    case reviewObservationCloseOutApprovedNF = 24
    case reviewObservationCloseOutRejectedNF = 25
    case reassignresponsiblePersonApprovedNF = 26
    case reassignresponsiblePersonRejectedNF = 27
    case groupMemberRoleChangedNF = 28
    case observationCreatedNF = 29
    case generalNF = 30
    case observationCreatedToResponsiblePersonNF = 31
    case observationClosedToResponsiblePersonNF = 32
    
    case preTaskBreifing = 33
}
