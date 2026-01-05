//
//  EmployeeListParams.swift
//  ALNASR
//
//  Created by Amarjith B on 15/09/25.
//

struct EmployeeListParams: Codable {
    var groupId: String?
    var searchKey: String?
    var pageNumber: Int?
    var sortType: SortedType?
}
