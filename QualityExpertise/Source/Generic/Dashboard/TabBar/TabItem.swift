//
//  TabItem.swift
// QualityExpertise
//
//  Created by developer on 26/01/22.
//

import Foundation

enum TabItem: Int, CaseIterable, Identifiable {
    
    case dashboard
    case projects
    case logo
    case notifications
    case menu
    
    var id: UUID {
        UUID()
    }

    var image: String? {
        switch self {
        case .dashboard:
            return IC.DASHBOARD.TAB.HOME
        case .projects:
            return IC.DASHBOARD.TAB.PROJECTS
        case .logo:
            return IC.LOGO.DASHBOARD_LOGO
        case .notifications:
            return IC.DASHBOARD.TAB.NOTIFICATIONS
        case .menu:
            return IC.DASHBOARD.TAB.MENU
        }
        
    }
    
    var selectedImage: String? {
        switch self {
        case .dashboard:
            return IC.DASHBOARD.TAB.HOME_SELECTED
        case .projects:
            return IC.DASHBOARD.TAB.PROJECTS_SELECTED
        case .logo:
            return IC.LOGO.DASHBOARD_LOGO
        case .notifications:
            return IC.DASHBOARD.TAB.NOTIFICATIONS_SELECTED
        case .menu:
            return IC.DASHBOARD.TAB.MENU_SELECTED
        }
        
    }
}

