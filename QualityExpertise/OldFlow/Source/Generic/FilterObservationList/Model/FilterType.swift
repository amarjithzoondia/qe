//
//  FilterType.swift
// ALNASR
//
//  Created by developer on 28/02/22.
//

import Foundation

enum FilterType: String, CaseIterable, Identifiable, Codable {
    var id: String {
        self.rawValue
    }
    
    case status
    case group
    case observer
    case responsible
    case date
    
    var description: String {
        switch self {
        case .status:
            return "Status"
        case .group:
            return "Group"
        case .observer:
            return "Observer"
        case .responsible:
            return "Responsible"
        case .date:
            return "Date"
        }
    }
}
