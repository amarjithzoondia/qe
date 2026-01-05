//
//  AuditsInspectionsList.swift
//  ALNASR
//
//  Created by Amarjith B on 04/06/25.
//

struct AuditsInspectionsList: Decodable, Identifiable {
    var auditItemId: Int
    var auditItemTitle: String
    var image: String?
    var formUpdatedTime: String?
    
    var id: Int { auditItemId }
    
    static func dummy() -> AuditsInspectionsList {
        return AuditsInspectionsList(auditItemId: 1, auditItemTitle: "", image: "")
    }
}

struct AuditsInspectionsListResponse: Decodable {
    let updatedTime: String?
    let contents: [AuditsInspectionsList]
}

