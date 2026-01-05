//
//  Menu.swift
// ALNASR
//
//  Created by developer on 31/01/22.
//

import SwiftUI

extension MoreMenuContentView {
    enum MoreMenu {
        case aboutUs
        case contactUs
        case settings
        case termsOfUse
        case privacyPolicy
        
        var title:String {
            switch self {
            case .aboutUs:
                return "About Us".localizedString()
            case .contactUs:
                return "Contact Us".localizedString()
            case .settings:
                return "Settings".localizedString()
            case .termsOfUse:
                return "Terms of use".localizedString()
            case .privacyPolicy:
                return "Privacy policy".localizedString()
            }
        }
        
        var icon: String{
            switch self {
            
            case .aboutUs:
                return IC.MENU.ABOUT_US
            case .contactUs:
                return IC.MENU.CONTACT_US
            case .settings:
                return IC.MENU.SETTINGS
            case .termsOfUse:
                return IC.MENU.TERMS_OF_USE
            case .privacyPolicy:
                return IC.MENU.PRIVACY_POLICY
            }
        }
    }
}

