//
//  ObservationRequest+Extension.swift
// QualityExpertise
//
//  Created by developer on 10/02/22.
//

import Foundation

extension ObservationRequest {
    struct ListParams: Encodable {
        var searchKey: String
        var status: Observation.Status
        var groupIds: [Int]
        var observers: [Int]
        var responsiblePersons: [Int]
        var openDate: String
        var closeDate: String
        var groupSpecified: Int
        var notificationId: Int
    }
    
    struct ListResponse: Decodable {
        var observations: [Observation]
        var notificationUnReadCount: Int?
        var pendingActionsCount: Int?
    }
    
    struct GusetListParams: Encodable {
        var guestUserId: Int
        var searchKey: String
    }
    
    struct ExportToexcelResponse: Decodable {
        var excelUrl: String
    }
}
