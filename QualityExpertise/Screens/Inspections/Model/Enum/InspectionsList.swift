//
//  InspectionsList.swift
//  ALNASR
//
//  Created by Amarjith B on 02/06/25.
//

enum InspectionsList: CaseIterable, Identifiable {
    
    case environment
    case fire
    case firstAidBox
    case liftingEquipment
    case generalAreaInspection
    case ppe
    case equipmentStatic
    case equipmentEarthMoving
    
    var id: String {title}
    
    var title: String {
        switch self {
        case .environment:
            return "Environment"
        case .fire:
            return "Fire"
        case .firstAidBox:
            return "First Aid Box"
        case .liftingEquipment:
            return "Lifting Equipment"
        case .generalAreaInspection:
            return "General Area Inspection"
        case .ppe:
            return "PPE"
        case .equipmentStatic:
            return "Equipment - Static"
        case .equipmentEarthMoving:
            return "Equipment - Earth Moving"
        }
    }
    
    var iconName: String {
        switch self {
        case .environment:
            return IC.INSPECTIONS.ENVIRONMENT
        case .fire:
            return IC.INSPECTIONS.FIRE
        case .firstAidBox:
            return IC.INSPECTIONS.FIRST_AID_BOX
        case .liftingEquipment:
            return IC.INSPECTIONS.LIFTING_EQUIPMENT
        case .generalAreaInspection:
            return IC.INSPECTIONS.GENERAL_AREA_INSPECTION
        case .ppe:
            return IC.INSPECTIONS.PPE
        case .equipmentStatic:
            return IC.INSPECTIONS.EQUIPMENT_STATIC
        case .equipmentEarthMoving:
            return IC.INSPECTIONS.EQUIPMENT_EARTH_MOVING
        }
    }
    
}
