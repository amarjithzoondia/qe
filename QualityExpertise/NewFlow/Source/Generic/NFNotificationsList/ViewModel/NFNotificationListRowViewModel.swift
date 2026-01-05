//
//  NFNotificationListRowViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import Foundation
import MapKit

class NFNotificationListRowViewModel {
    let notification: AppNotification
    
    init(notification: AppNotification) {
        self.notification = notification
    }
    
    var dateText: String {
        return notification.date?.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", local: LocalizationService.shared.language.local) ?? ""
    }
    
    var timeText: String {
        return Date().timeAgo(from: notification.date?.repoDate(inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", local: LocalizationService.shared.language.local)?.toLocalTime() ?? Date())
    }
    
    var groupCode: String {
        return "ID" + Constants.SPACE + (notification.groupCode ?? "")
    }
}
