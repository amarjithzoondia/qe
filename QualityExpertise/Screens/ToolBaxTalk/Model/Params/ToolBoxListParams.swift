//
//  ToolBoxListParams.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/09/25.
//

struct ToolBoxListParams: Codable {
    var searchKey: String?
    var pageNumber: Int
    var sortType: SortedType
    var projectIds: [Int]
    var openDate: String
    var endDate: String
    var reportedByPersons: [Int]
}
