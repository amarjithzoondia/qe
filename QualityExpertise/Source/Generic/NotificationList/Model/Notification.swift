//
//  Notification.swift
// QualityExpertise
//
//  Created by developer on 07/03/22.
//

import Foundation

struct Notification: Decodable {
    var id: Int
    var type:Int
    var contentId: Int?
    var title: String?
    var time:String?
    var date: String?
    var description:String?
    var groupCode: String?
    var isRead: Bool
}
