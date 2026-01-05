//
//  ToolBoxExcelParams.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/09/25.
//

struct ToolBoxExcelParams: Encodable {
    var searchKey: String
    var sortBy: SortedType
    var projectIds: [Int]
    var openDate: String
    var endDate: String
    var reportedByPersons: [Int]
}

struct ToolBoxExcelResponse: Decodable {
    var excelUrl: String
}
