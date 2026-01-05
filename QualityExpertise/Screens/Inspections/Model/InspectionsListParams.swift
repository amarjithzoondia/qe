//
//  InspectionsListParams.swift
//  ALNASR
//
//  Created by Amarjith B on 04/06/25.
//

struct InspectionsListParams: Codable {
    var searchKey: String?
    var pageNumber: Int
    var sortType: SortedType
    var projectIds: [Int]
    var openDate: String
    var endDate: String
    var reportedByPersons: [Int]
}
