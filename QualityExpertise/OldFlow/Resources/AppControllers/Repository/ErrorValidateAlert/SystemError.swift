//
//  SystemError.swift
// ALNASR
//
//  Created by Developer on 22/07/21.
//

import Foundation

class SystemError: Error, Identifiable {
    enum ErrorType: CustomStringConvertible {
        case alert
        case error
        case validation
        case info
        
        var description: String {
            switch self {
            case .alert:
                return "Alert!".localizedString()
            case .error:
                return "Error!".localizedString()
            case .validation:
                return "Validation!".localizedString()
            case .info:
                return "Info".localizedString()
            }
        }
    }
    
    let type: ErrorType
    let errorCode: Int?
    let message: String
    let title: String?
    let response: Any?
    let statusCode: Int?
    
    internal init(_ message: String, type: ErrorType = .alert, title: String? = nil, errorCode: Int? = nil, response: Any? = nil, statusCode: Int? = nil) {
        self.message = message
        self.type = type
        self.title = title
        self.errorCode = errorCode
        self.response = response
        self.statusCode = statusCode
    }
}

extension SystemError {
    var toast: AlertToast {
        Toast.alert(title: type.description, subTitle: message, isSuccess: false)
    }
    
    func viewRetry(isDarkMode: Bool = false, action: @escaping () -> Void) -> ErrorRetryView {
        ErrorRetryView(retry: { action() },
                       title: nil,
                       message: self.message,
                       isDarkMode: isDarkMode)
    }
}

extension Error {
    var toast: AlertToast {
        Toast.alert(title: "Error!".localizedString(), subTitle: localizedDescription, isSuccess: false)
    }
}

extension String {
    var successToast: AlertToast {
        Toast.alert(title: "Success".localizedString(), subTitle: self, isSuccess: true)
    }
}

extension String {
    func viewRetry(isDarkMode: Bool = false, action: @escaping () -> Void) -> ErrorRetryView {
        ErrorRetryView(retry: { action() },
                       title: nil,
                       message: self,
                       isDarkMode: isDarkMode)
    }
}
