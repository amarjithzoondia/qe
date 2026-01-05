//
//  AlertToastHelper.swift
// ALNASR
//
//  Created by developer on 18/01/22.
//

import Foundation

import SwiftUI

struct Toast {
    public enum AlertToastTheme: Equatable {
        case light
        case dark
    }
    
    static func alert(title: String = "Alert!".localizedString(), subTitle: String, displayMode: AlertToast.DisplayMode = .banner(.slide), isSuccess: Bool = false) -> AlertToast {
        let backgroundColor: Color = isSuccess ? Color.Blue.THEME : Color.Red.LIGHT
        let titleColor: Color = .white
        let subTitleColor: Color = .white
        let style = AlertToast.AlertStyle.style(backgroundColor: backgroundColor,
                                          titleColor: titleColor,
                                          subTitleColor: subTitleColor,
                                          titleFont: .semiBold(14),
                                          subTitleFont: .light(12))
        let toast = AlertToast(displayMode: displayMode, type: .regular,
                               title: title,
                               subTitle: subTitle,
                               style: style)
        
        return toast
    }
}
