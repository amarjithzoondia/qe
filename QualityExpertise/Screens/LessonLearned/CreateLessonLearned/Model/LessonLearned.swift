//
//  LessonLearned.swift
//  QualityExpertise
//
//  Created by Amarjith B on 18/07/25.
//

struct LessonLearned: Identifiable, Decodable {
    var id: Int
    var title: String
    var description: String?
    var createdAt: String
    var facilities: GroupData?
    var images: [ImageData]?
    var reportedBy: String
    
    static func dummy() -> LessonLearned {
        return LessonLearned(id: -1, title: "Test", description: "Test", createdAt: "2025-06-23T09:33:39.412091Z", facilities: GroupData.dummy(), reportedBy: UserManager.getLoginedUser()?.name ?? "")
    }
}
