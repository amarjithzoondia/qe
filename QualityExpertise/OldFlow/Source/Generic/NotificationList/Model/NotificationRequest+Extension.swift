//
//  NotificationRequest+Extension.swift
// ALNASR
//
//  Created by developer on 07/03/22.
//

import Foundation

extension NotificationRequest {
    struct ListResponse: Decodable {
        var notifications: [AppNotification]
        var notificationUnReadCount: Int
        var pendingActionsCount: Int
    }
}
