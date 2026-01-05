//
//  ViolationParams.swift
//  ALNASR
//
//  Created by Amarjith B on 21/07/25.
//

struct ViolationParams: Codable {
    var facilitiesId: String?
    var employeeName: String
    var employeeId: String
    var violationDate: String
    var location: String?
    var description: String?
    var images: [ImageData]?
    var reportedBy: String
}

struct ViolationCreationResponse: Codable {
    let violationId: Int
    let statusMessage: String
}
