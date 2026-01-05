//
//  Alert+Extension.swift
// ALNASR
//
//  Created by developer on 18/01/22.
//

import SwiftUI

extension Alert {
    static func alert(type: SystemError.ErrorType = .alert,
                      title: String? = nil,
                      message: String? = nil,
                      completionHandler: (() -> ())? = nil) -> Alert {
        
        let dismissButtonTitle = "ok".localizedString()
        let title = Text(title ?? type.description)
        let message: Text? = message == nil ? nil : Text(message ?? "")
        return Alert(
            title: title,
            message: message,
            dismissButton: .cancel(Text(dismissButtonTitle), action: {
                completionHandler?()
            })
        )
    }
}

