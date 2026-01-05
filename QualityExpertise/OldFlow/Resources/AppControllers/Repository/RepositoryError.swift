//
//  RepositoryError.swift
// ALNASR
//
//  Created by Vivek M on 04/03/21.
//

import Foundation

extension Repository {
    public enum ErrorCode: Int {
        case unknown
        case networkConnectionError = -1001
        case networkConnectionLost = -1009
        case sessionTimeout = 401
        case parsingError = -2
        case validation = -3
        case maintanance = 503
        case unauthorizedAccess = 2020
        case observationNotFound = 1004
        case noAccessToGroup = 1005
        case refreshGroupDetails = 1006
    }
}
