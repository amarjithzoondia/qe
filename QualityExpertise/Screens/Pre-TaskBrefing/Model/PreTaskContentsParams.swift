//
//  PreTaskContentsParams.swift
//  ALNASR
//
//  Created by Amarjith B on 27/10/25.
//

struct PreTaskContentsParams: Codable {
    var contentsUpdatedTime: String?
    var questionsUpdatedTime: String?
}

struct PreTaskDetailParams: Codable {
    var id: Int
}

struct PreTaskParams: Codable {
    var date: String
    var startTime: String
    var endTime: String
    var taskTitle: String

    var msraReference: String?
    var permitReference: String?

    var contents: [PreTaskAPI.Content]?
    var questions: [PreTaskAPI.Question]?
    var otherTopic: [PreTaskQuestion]?

    var attendees: [Employee]
    var images: [ImageData]?
    var facilitiesId: String?
    var notes: String?

    var createdAt: String
    var reportedBy: String
    var sendNotificationTo: [Int]?
}

struct PreTaskResponse: Codable {
    var preTaskId: Int
    var statusMessage: String
}

struct PreTaskListParams: Codable {
    var searchKey: String?
    var pageNumber: Int
    var sortType: SortedType
    var projectIds: [Int]
    var openDate: String
    var endDate: String
    var reportedByPersons: [Int]
}
