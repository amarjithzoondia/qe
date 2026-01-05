//
//  IncidentListParams.swift
//  ALNASR
//
//  Created by Amarjith B on 10/09/25.
//

struct IncidentListParams: Codable {
    var searchKey: String?
    var pageNumber: Int
    var sortType: SortedType
    var projectIds: [Int]
    var openDate: String
    var endDate: String
    var reportedByPersons: [Int]
    var incidentTypes: [Int]
}
