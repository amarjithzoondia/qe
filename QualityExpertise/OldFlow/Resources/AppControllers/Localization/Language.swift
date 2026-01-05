//
//  Language.swift
// ALNASR
//
//  Created by Developer on 02/11/21.
//

import Foundation

enum Language: String, CaseIterable, Identifiable {
    var id: String {
        rawValue
    }
    
    case english = "en"
    
    
    var repoValue: String {
        switch self {
        case .english:
            return "1"
        }
    }
    
    var description: String {
        switch self {
        case .english:
            return "English"
        }
    }
}


