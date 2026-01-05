//
//  AppDelegate.swift
// ALNASR
//
//  Created by developer on 31/01/22.
//

import UIKit
import Foundation
import SwiftUI
import GoogleMobileAds
import Firebase
import AppTrackingTransparency
import AdSupport
import FacebookCore

class AppDelegate: NSObject, UIApplicationDelegate {
    
    static var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        func registerRemoteNotifications() {

            UNUserNotificationCenter.current().delegate = self
            Messaging.messaging().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
            
            application.registerForRemoteNotifications()
            
        }
        
        func initialiseSDKs() {
            FirebaseApp.configure()
        }
        
        initialiseSDKs()
        registerRemoteNotifications()

        if Int(Configurations.AD.IS_TEST_AD ?? "") == 1 {
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers =
                [ UIDevice.current.identifierForVendor!.uuidString ]
        }
        
        if Configurations.isDebug {
            Settings.shared.isAutoLogAppEventsEnabled = true
            Settings.shared.isAdvertiserTrackingEnabled = true
        } else {
            Settings.shared.isAutoLogAppEventsEnabled = true
            Settings.shared.isAdvertiserTrackingEnabled = true
        }
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .badge, .sound])//To get notification in foreground
        Log.print("willPresent Notification Response \(notification.request.content.userInfo)")
        guard let pushType = (notification.request.content.userInfo["pushType"] as? String)?.toInt else { return }
        let notificationPushType = PushType(rawValue: pushType)
        if notificationPushType == .notification {
            UserManager.instance.notificationUnReadCount = UserManager.instance.notificationUnReadCount + 1
            NotificationCenter.default.post(name: .UPDATE_COUNT, object: nil)
        } else {
            UserManager.instance.pendingActionsCount = UserManager.instance.pendingActionsCount + 1
            NotificationCenter.default.post(name: .UPDATE_COUNT, object: nil)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
        guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else { return }
        Log.print("didReceive Notification Response \(response.notification.request.content.userInfo)")
        if let userInfo = response.notification.request.content.userInfo as? [String: Any] {
            NotificationManager.manage(userInfo)
        }
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        NotificationManager.shared.firebaseToken = fcmToken
    }
}

extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // set to `false` if you don't want to detect tap during other gestures
    }
}

