//
//  LessonLearnedListParams.swift
//  QualityExpertise
//
//  Created by Amarjith B on 21/07/25.
//

struct LessonLearnedListParams: Codable {
    var searchKey: String?
    var pageNumber: Int
    var sortType: SortedType
    var projectIds: [Int]
    var openDate: String
    var endDate: String
    var reportedByPersons: [Int]
}
