//
//  NSNotificationNames.swift
// QualityExpertise
//
//  Created by developer on 18/02/22.
//

import Foundation

extension NSNotification.Name {
    static let CLOSE_BOOKING_FLOW = NSNotification.Name("CLOSE_BOOKING_FLOW")
    static let UPDATE_GROUP = NSNotification.Name("UPDATE_GROUP")
    static let DELETE_GROUP = NSNotification.Name("DELETE_GROUP")
    static let CLOSE_OBSERVATION = NSNotification.Name("CLOSE_OBSERVATION")
    static let DELETE_OBSERVATION = NSNotification.Name("DELETE_OBSERVATION")
    static let RELAUNCH_APP = NSNotification.Name("RELAUNCH_APP")
    static let UPDATE_DRAFT = NSNotification.Name("UPDATE_DRAFT")
    static let UPDATE_PROFILE = NSNotification.Name("UPDATE_PROFILE")
    static let APP_NOTIFICATION_CLICKED = NSNotification.Name("APP_NOTIFICATION_CLICKED")
    static let UPDATE_PENDINGACTION = NSNotification.Name("UPDATE_PENDINGACTION")
    static let UPDATE_COUNT = NSNotification.Name("UPDATE_COUNT")
    static let UPDATE_GROUP_LIST = NSNotification.Name("UPDATE_GROUP_LIST")
    static let UPDATE_NOTIFICATION_LIST = NSNotification.Name("UPDATE_NOTIFICATION_LIST")
    static let UPDATE_INSPECTIONS_LIST = NSNotification.Name("UPDATE_INSPECTIONS_LIST")
}
