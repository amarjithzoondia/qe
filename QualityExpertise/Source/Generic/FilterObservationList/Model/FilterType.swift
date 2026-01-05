//
//  FilterType.swift
// QualityExpertise
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
            return "status".localizedString()
        case .group:
            return "group".localizedString()
        case .observer:
            return "observer".localizedString()
        case .responsible:
            return "responsible".localizedString()
        case .date:
            return "date".localizedString()
        }
    }

}
