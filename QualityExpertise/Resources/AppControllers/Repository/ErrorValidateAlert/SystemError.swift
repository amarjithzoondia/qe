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
                return "alert".localizedString()
            case .error:
                return "error".localizedString()
            case .validation:
                return "validation".localizedString()
            case .info:
                return "info".localizedString()
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
    
    func viewRetry(isDarkMode: Bool = false, isError: Bool = false, action: @escaping () -> Void) -> ErrorRetryView {
        ErrorRetryView(retry: { action() },
                       title: nil,
                       message: self.message,
                       isDarkMode: isDarkMode,
                       isError: isError)
    }
}

extension Error {
    var systemError: SystemError {
        if let error = self as? SystemError {
            return error
        }
        
        return SystemError(self.localizedDescription)
    }
}

extension Error {
    var toast: AlertToast {
        Toast.alert(title: "error".localizedString(), subTitle: localizedDescription, isSuccess: false)
    }
}

extension String {
    var successToast: AlertToast {
        Toast.alert(title: "success".localizedString(), subTitle: self, isSuccess: true)
    }
    
    var infoToast: AlertToast {
        Toast.alert(title: "info".localizedString(), subTitle: self, isSuccess: true)
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
