//
//  UserRole.swift
// ALNASR
//
//  Created by developer on 27/01/22.
//

import Foundation

enum UserRole: Int, Identifiable, CaseIterable, Codable {
    var id: Int {
        self.rawValue
    }
    
    case none = -1
    case superAdmin = 1
    case admin = 2
    case participant = 3
    
    var description: String {
        switch self {
        case .none:
            return ""
        case .superAdmin:
            return "Super Admin"
        case .admin:
            return "Admin"
        case .participant:
            return "Participant"
        }
    }

}
