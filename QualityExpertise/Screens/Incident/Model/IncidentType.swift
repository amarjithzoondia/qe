//
//  IncidentType.swift
//  ALNASR
//
//  Created by Amarjith B on 10/09/25.
//

enum IncidentType: CaseIterable, Identifiable {
    
    case fatality
    case hospital
    case roadTraffic
    case dangerous
    case nonAccidentDeath
    case propertyDamage
    case significantEnvironmentalIncident
    case other
    
    var id: Int {
        switch self {
        case .fatality:
            1
        case .hospital:
            2
        case .roadTraffic:
            3
        case .dangerous:
            4
        case .nonAccidentDeath:
            5
        case .propertyDamage:
            6
        case .significantEnvironmentalIncident:
            7
        case .other:
            8
        }
    }
    
    var title: String {
        switch self {
        case .fatality:
            "fatality".localizedString()
        case .hospital:
            "hospitalization".localizedString()
        case .roadTraffic:
            "road_traffic_accident".localizedString()
        case .dangerous:
            "dangerous_occurrence".localizedString()
        case .nonAccidentDeath:
            "non_accidental_death".localizedString()
        case .propertyDamage:
            "property_damage".localizedString()
        case .significantEnvironmentalIncident:
            "significant_environmental_incident".localizedString()
        case .other:
            "other".localizedString()
        }
    }


}

extension IncidentType {
    static func from(id: Int) -> IncidentType? {
        return Self.allCases.first { $0.id == id }
    }
}
