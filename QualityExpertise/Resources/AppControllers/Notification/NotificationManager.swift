//
//  NotificationManager.swift
// QualityExpertise
//
//  Created by developer on 16/03/22.
//

import Foundation
import FirebaseMessaging

extension String {
    func toDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

class NotificationManager: ObservableObject {
    public static let shared = NotificationManager()
    var pageToNavigationForNotification: AppNotification? {
        didSet {
            if let newValue = pageToNavigationForNotification {
                NotificationCenter.default.post(
                    name: .APP_NOTIFICATION_CLICKED,
                    object: nil,
                    userInfo: [Constants.NotificationKey.USER_INFO: newValue])
            }
        }
    }
    
    var savedForLaterNotification: AppNotification?
    var firebaseToken: String?
    
    class func manage(_ userInfo: [String: Any], from isLaunching: Bool = false) {
        guard UserManager().isLogined else { return }
        guard let detail = (userInfo["details"] as? String)?.toDictionary()  else { return }
        guard let appNotification = DataManager.parse(data: detail, to: AppNotification.self) as? AppNotification else { return }
        guard let pushType = (userInfo["pushType"] as? String)?.toInt else { return }
        appNotification.pushType = PushType(rawValue: pushType)
        if isLaunching {
            NotificationManager.saveForLater(notification: appNotification)
        } else {
            NotificationManager.show(notification: appNotification)
        }
    }
    
    class func saveForLater(notification: AppNotification) {
        NotificationManager.shared.savedForLaterNotification = notification
    }

    class func show(notification: AppNotification) {
        NotificationManager.shared.pageToNavigationForNotification = notification
        
    }
 
}

