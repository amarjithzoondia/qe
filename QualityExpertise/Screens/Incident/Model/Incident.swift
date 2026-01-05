//
//  Incident.swift
//  ALNASR
//
//  Created by Amarjith B on 10/09/25.
//

struct Incident: Decodable {
    var id: Int
    var incidentDate: String
    var incidentTime: String
    var incidentLocation: String?
    var incidentType: [Int]
    var injuredEmployees: [Employee]?
    var description: String?
    var corrections: String?
    var createdAt: String
    var facilities: GroupData?
    var images: [ImageData]?
    var reportedBy: String
    
    static func dummmy() -> Incident {
        return Incident(id: -1, incidentDate: "2025-09-12 10:55:42", incidentTime: "10:55:45", incidentType: [1,2,3,4,5], injuredEmployees: [.dummy(),.dummy()], corrections: "", createdAt: "2025-09-12 10:19:00", reportedBy: UserManager.getLoginedUser()?.name ?? "")
    }
}
