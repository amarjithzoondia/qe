//
//  NotificationListRowViewModel.swift
// ALNASR
//
//  Created by developer on 07/03/22.
//

import Foundation
import MapKit

class NotificationListRowViewModel {
    let notification: AppNotification
    
    init(notification: AppNotification) {
        self.notification = notification
    }
    
    var dateText: String {
        return notification.date?.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") ?? ""
    }
    
    var timeText: String {
        return Date().timeAgo(from: notification.date?.repoDate(inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")?.toLocalTime() ?? Date())
    }
    
    var groupCode: String {
        return "ID" + Constants.SPACE + (notification.groupCode ?? "")
    }
}
