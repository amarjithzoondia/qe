//
//  ToolBoxTalk.swift
//  QualityExpertise
//
//  Created by Amarjith B on 15/09/25.
//

struct ToolBoxTalk: Decodable {
    var id: Int
    var date: String
    var startTime: String
    var endTime: String
    var topic: String
    var discussionPoints: [DiscussionPoint]
    var attendees: [Employee]?
    var createdAt: String
    var facilities: GroupData?
    var images: [ImageData]?
    var reportedBy: String
    
    static func dummmy() -> ToolBoxTalk {
        return ToolBoxTalk(id: -1, date: "2025-09-12 10:55:42", startTime: "10:55:45", endTime: "10:55:45", topic: "Sample Topic", discussionPoints: [.dummy(),.dummy()], attendees: [.dummy(),.dummy()], createdAt: "2025-09-12 10:19:00", facilities: .dummy(), images: [.dummy(imageCount: 1)], reportedBy: UserManager.getLoginedUser()?.name ?? "")
    }
}
