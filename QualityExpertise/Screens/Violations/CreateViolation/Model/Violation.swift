//
//  Violation.swift
//  ALNASR
//
//  Created by Amarjith B on 18/07/25.
//

struct Violation: Identifiable, Decodable {
    var id: Int
    var employeeName: String
    var employeeId: String
    var violationDate: String
    var location: String?
    var description: String?
    var createdAt: String
    var facilities: GroupData?
    var images: [ImageData]?
    var reportedBy: String
    
    static func dummy() -> Violation {
        return Violation(id: -1, employeeName: "Test User", employeeId: "AD12H", violationDate: "2025-06-23T09:33:39.412091Z", location: "Sample Location", description: "Test", createdAt: "2025-06-23T09:33:39.412091Z", facilities: GroupData.dummy(), reportedBy: UserManager.getLoginedUser()?.name ?? "")
    }
}
