//
//  IncidentExcelParams.swift
//  ALNASR
//
//  Created by Amarjith B on 10/09/25.
//

struct IncidentExcelParams: Encodable {
    var searchKey: String
    var sortBy: SortedType
    var projectIds: [Int]
    var openDate: String
    var endDate: String
    var reportedByPersons: [Int]
    var incidentTypes: [Int]
}

struct IncidentExcelResponse: Decodable {
    var excelUrl: String
}
