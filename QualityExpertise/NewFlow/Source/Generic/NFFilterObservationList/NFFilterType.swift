//
//  NFFilterType.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import Foundation

enum NFFilterType: String, CaseIterable, Identifiable, Codable {
    var id: String {
        self.rawValue
    }
    
    case status
    case project
    case observer
    case responsible
    case date
    
    var description: String {
        switch self {
        case .status:
            return "status".localizedString()
        case .project:
            return "project".localizedString()
        case .observer:
            return "observer".localizedString()
        case .responsible:
            return "responsible".localizedString()
        case .date:
            return "date".localizedString()
        }
    }
}
