//
//  InspectionExcelParams.swift
//  ALNASR
//
//  Created by Amarjith B on 09/06/25.
//
 
struct InspectionExcelParams: Encodable {
    var searchKey: String
    var sortBy: SortedType
    var projectIds: [Int]
    var openDate: String
    var endDate: String
    var reportedByPersons: [Int]
}

struct InspectionExcelResponse: Decodable {
    var excelUrl: String
}

enum SortedType: Int, Codable {
    case descending = 1
    case ascending = 2
}
