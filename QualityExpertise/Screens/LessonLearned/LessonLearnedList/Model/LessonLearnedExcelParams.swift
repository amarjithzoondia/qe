//
//  LessonLearnedExcelParams.swift
//  QualityExpertise
//
//  Created by Amarjith B on 21/07/25.
//

struct LessonLearnedExcelParams: Encodable {
    var searchKey: String
    var sortBy: SortedType
    var projectIds: [Int]
    var openDate: String
    var endDate: String
    var reportedByPersons: [Int]
}

struct LessonLearnedExcelResponse: Decodable {
    var excelUrl: String
}
