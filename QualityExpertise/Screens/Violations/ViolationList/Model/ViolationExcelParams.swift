//
//  ViolationExcelParams.swift
//  ALNASR
//
//  Created by Amarjith B on 21/07/25.
//

struct ViolationExcelParams: Encodable {
    var searchKey: String
    var sortBy: SortedType
    var projectIds: [Int]
    var openDate: String
    var endDate: String
    var reportedByPersons: [Int]
}

struct ViolationExcelResponse: Decodable {
    var excelUrl: String
}
