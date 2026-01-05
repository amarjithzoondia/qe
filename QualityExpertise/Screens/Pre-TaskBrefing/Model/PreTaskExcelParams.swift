//
//  ToolBoxExcelParams.swift
//  ALNASR
//
//  Created by Amarjith B on 28/10/25.
//


struct PreTaskExcelParams: Encodable {
    var searchKey: String
    var sortBy: SortedType
    var projectIds: [Int]
    var openDate: String
    var endDate: String
    var reportedByPersons: [Int]
}

struct PreTaskExcelResponse: Decodable {
    var excelUrl: String
}

struct PreTaskPdfParams: Codable {
    var preTaskId: Int
}
struct PreTaskPdfResponse: Decodable {
    var pdfUrl: String
}
