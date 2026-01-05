//
//  IncidentParams.swift
//  ALNASR
//
//  Created by Amarjith B on 10/09/25.
//

struct IncidentParams: Codable {
    var incidentDate: String
    var incidentTime: String
    var incidentLocation: String?
    var incidentType: [Int]
    var injuredEmployees: [Employee]
    var description: String?
    var corrections: String?
    var createdAt: String
    var facilitiesId: String?
    var images: [ImageData]?
    var reportedBy: String
}

struct IncidentCreationResponse: Codable {
    let incidentId: Int
    let statusMessage: String
}
