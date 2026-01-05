//
//  DiscussionPoint.swift
//  QualityExpertise
//
//  Created by Amarjith B on 15/09/25.
//

struct DiscussionPoint: Codable {
    var id: Int
    var point: String
    
    static func dummy() -> DiscussionPoint {
        return DiscussionPoint(id: -1, point: "Sample")
    }
}
