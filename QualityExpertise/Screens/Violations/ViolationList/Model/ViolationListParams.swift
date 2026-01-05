//
//  ViolationListParams.swift
//  ALNASR
//
//  Created by Amarjith B on 21/07/25.
//

struct ViolationListParams: Codable {
    var searchKey: String?
    var pageNumber: Int
    var sortType: SortedType
    var projectIds: [Int]
    var openDate: String
    var endDate: String
    var reportedByPersons: [Int]
}
