//
//  ToolBoxParams.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/09/25.
//

struct ToolBoxParams: Codable {
    var date: String
    var startTime: String
    var endTime: String
    var topic: String
    var discussionPoints: [DiscussionPoint]
    var attendees: [Employee]?
    var createdAt: String
    var facilitiesId: String?
    var images: [ImageData]?
    var reportedBy: String
}

struct ToolBoxCreationResponse: Codable {
    let toolBoxTalkId: Int
    let statusMessage: String
}
