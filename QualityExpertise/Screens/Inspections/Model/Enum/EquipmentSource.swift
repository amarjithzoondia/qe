//
//  EquipmentSource.swift
//  ALNASR
//
//  Created by Amarjith B on 02/06/25.
//

enum EquipmentSource: Int, CaseIterable, Codable {
    case alnasar = 1
    case rental = 2
    case subcontractor = 3
    
    var title: String {
        switch self {
        case .alnasar:
            return "alnasr".localizedString().uppercased()
        case .rental:
            return "rental".localizedString().uppercased()
        case .subcontractor:
            return "subcontractor".localizedString().uppercased()
        }
    }
}
