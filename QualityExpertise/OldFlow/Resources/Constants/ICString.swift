//
//  ICString.swift
// ALNASR
//
//  Created by developer on 18/01/22.
//

import Foundation

struct IC {
    struct LOGO {
        static let SPLASH_LOGO = "ic.logo.splash"
        static let SPLASH_REPORT = "ic.report.text.splash"
        static let SPLASH_ON_THE_GO = "ic.onthego.spalsh"
        static let OTP = "ic.logo.otp"
        static let DASHBOARD_LOGO = "ic.logo.dashboard"
        static let SUCCESS = "ic.logo.group.creation.success"
        static let REQUEST_ACCESS = "ic.requestAccess.logo"
        static let ABOUT_US = "ic.logo.aboutus"
        static let CONTACT_US = "ic.logo.contactus"
        static let DASH = "ic.logo.dash"
        static let USER_CLEAR = "ic.logo.user.clear"
        static let SEND_BLUE = "ic.logo.send.blue"
        static let TRASH_CAN = "ic.logo.trash"
        static let NOTIFCATIONS_CLEAR = "ic.logo.notification.clear"
    }
    
    struct MENU {
        static let ABOUT_US = "ic.aboutus"
        static let CONTACT_US = "ic.contactus"
        static let SETTINGS = "ic.settings"
        static let TERMS_OF_USE = "ic.termsofuse"
        static let PRIVACY_POLICY = "ic.privacypolicy"
    }
    
    struct PLACEHOLDER {
        static let EMAIL = "ic.email"
        static let PASSWORD = "ic.password"
        static let EYE_CLOSE = "ic.eye.close"
        static let EYE_OPEN = "ic.eye.open"
        static let USER = "ic.placeholder.user"
        static let COMMON = "ic.placeholder.common"
        static let CALENDER = "ic.calender"
        static let LOCATION = "ic.location"
        static let LOGO = "ic.placeholder.logo"
        static let GROUP = "ic.placeholder.group"
    }
    
    struct INDICATORS {
        static let BLUE_FORWARD_ARROW = "ic.blue.forward.arrow"
        static let BLACK_BACKWARD_ARROW = "ic.black.backward.arrow"
        static let WHITE_FORWARD_ARROW = "ic.white.forward.arrow"
        static let GOTO_RIGHT_ARROW_GREY = "ic.grey.goto.right.arrow"
        static let WHITE_BACKWARD_ARROW = "ic.white.backward.arrow"
    }
    
    struct ACTIONS {
        static let ADD_PROFILE_IMAGE = "ic.actions.add.profile.image"
        static let SHARE = "ic.share"
        static let MINUS = "ic.minus"
        static let SEARCH = "ic.search"
        static let SEARCH_BLACK = "ic.search.black"
        static let CHECKBOX_OFF = "ic.checkbox.off"
        static let CHECKBOX_ON = "ic.checkbox.on"
        static let CLOSE_WHITE = "ic.close.white"
        static let CLOSE = "ic.close"
        static let TOGGLE_ON = "ic.toggle.on"
        static let TOGGLE_OFF = "ic.toggle.off"
        static let CAMERA_PICK = "ic.camera.pick"
        static let PLUS = "ic.plus"
        static let EDIT_BLACK = "ic.edit.black"
        static let FILTER = "ic.filter"
        static let SORT = "ic.sort"
        static let SORT_REVERSE = "ic.sort.reverse"
        static let ADD_PEOPLE = "ic.add.people"
        static let TICK = "ic.tick"
        static let MY_PENDING_ACTION = "ic.my.pendingaction"
        static let ALL_PENDING_ACTION = "ic.all.pendingaction"
        
        struct UPLOAD {
            static let PENDING = "ic.actions.upload.pending"
            static let PENDING_WHITE = "ic.actions.upload.pending.white"
            static let COMPLETED = "ic.actions.upload.completed"
        }
        
        struct RADIO_BUTTON {
            static let ON = "ic.radio.on"
            static let OFF = "ic.radio.off"
        }
    }
    
    struct DASHBOARD {
        static let VIEW_OBSERVATION = "ic.dashboard.view.observation"
        static let CREATE_OBSERVATION = "ic.dashboard.create.observation"
        static let DRAFT_OBSERVATION = "ic.dashboard.draft.observation"
        static let VIEW_GROUP = "ic.dashboard.view.group"
        static let INVITE_GROUP = "ic.dashboard.invite.group"
        static let REQUEST_GROUP = "ic.dashboard.request.access.group"
        static let CREATE_GROUP = "ic.dashboard.create.group"
        
        struct TAB {
            static let HOME = "ic.tab.home"
            static let PENDING_ACTIONS = "ic.tab.pendingactions"
            static let NOTIFICATIONS = "ic.tab.notifications"
            static let MENU = "ic.tab.menu"
            static let HOME_SELECTED = "ic.tab.home.selected"
            static let PENDING_ACTIONS_SELECTED = "ic.tab.pendingactions.selected"
            static let NOTIFICATIONS_SELECTED = "ic.tab.notifications.selected"
            static let NOTIFICATION_SELECTED_UNREAD = "ic.tab.notifictions.selected.unread"
            static let NOTIFICATION_UNREAD = "ic.tab.notifictions.unread"
            static let PENDING_ACTIONS_SELECTED_UNREAD = "ic.tab.pendingactions.selected.unread"
            static let PENDING_ACTIONS_UNREAD = "ic.tab.pendingactions.unread"
            static let MENU_SELECTED = "ic.tab.menu.selected"
            static let LOGO = "ic.dashboard.tab.logo"
            static let SETTINGS = "ic.settins"
            static let SETTINGS_SELECTED = "ic.settings.selected"
            static let PROJECTS = "ic.tab.projects"
            static let PROJECTS_SELECTED = "ic.tab.projects.selected"
        }
    }
    
    struct CONTACT_US {
        static let ADDRESS = "ic.contact.address"
        static let EMAIL = "ic.contact.email"
        static let PHONE = "ic.contact.phone"
    }
    
    struct SHARE {
        static let WHATSAPP = "ic.whatsapp"
        static let PDF_DOCUMENT = "ic.pdfDocument"
        static let TEXT_DOCUMENT = "ic.txtDocument"
    }
    
    struct INSPECTIONS {
        static let ENVIRONMENT = "ic.inspections.environment"
        static let FIRE = "ic.inspections.fire"
        static let FIRST_AID_BOX = "ic.inspections.firstaid"
        static let LIFTING_EQUIPMENT = "ic.inspections.lifting"
        static let GENERAL_AREA_INSPECTION = "ic.inspections.general"
        static let PPE = "ic.inspections.ppe"
        static let EQUIPMENT_STATIC = "ic.inspections.static"
        static let EQUIPMENT_EARTH_MOVING = "ic.inspections.earth"
    }
    
    struct HOMESCREEN {
        static let SEARCH = "ic.home.search"
        static let HELMET = "ic.home.helmet"
        static let PIPE = "ic.home.pipe"
        static let TOOLBOX = "ic.home.toolbox"
        static let SECURITY = "ic.home.security"
        static let TELESCOPE = "ic.home.telescope"
        static let LIST = "ic.home.list"
    }
}
