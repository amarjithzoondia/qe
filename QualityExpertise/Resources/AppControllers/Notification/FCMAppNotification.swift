//
//  FCMNotificationListModel.swift
// QualityExpertise
//
//  Created by developer on 17/03/22.
//

import Foundation
import SwiftUI

struct FCMAppNotification: Codable {
    var title: String?
    var body: String?
    var details: AppNotification
    var notificationSound: String?
    var badge: String?
    var image: String?
    var pushType: Int?
    
    var typeRaw: PushType? {
        if let type = pushType {
            return PushType(rawValue: type)
        }
        return nil
    }
}

