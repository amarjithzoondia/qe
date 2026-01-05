//
//  NFFilterActionType.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import Foundation
import SwiftUI

enum NFPendingActionType: Int, CaseIterable, Codable {
    case openObservation = 1
    case requestToJoinProject
    case observationResponsibilityChange
    case requestToDeleteObservation
    case reviewObservationCloseOut
    
    var description: String {
        switch self {
        case .openObservation:
            return "open_observation".localizedString()
        case .requestToJoinProject:
            return "request_to_join_group".localizedString()
        case .observationResponsibilityChange:
            return "observation_responsibility_change".localizedString()
        case .requestToDeleteObservation:
            return "request_to_delete_observation".localizedString()
        case .reviewObservationCloseOut:
            return "review_observation_closeout".localizedString()
        }
    }
    
    var textColor: Color {
        switch self {
        case .openObservation:
            return Color.Green.GREEN_BLUE
        case .requestToJoinProject:
            return Color.Blue.BRIGHT_SKY_BLUE
        case .observationResponsibilityChange:
            return Color.Red.SALMON
        case .requestToDeleteObservation:
            return Color.Violet.CORN_FLOWER
        case .reviewObservationCloseOut:
            return Color.Orange.MACRONI_AND_CHEESE
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .openObservation:
            return Color.Green.ICE
        case .requestToJoinProject:
            return Color.Blue.ICE
        case .observationResponsibilityChange:
            return Color.Red.VERY_LIGHT_PINK
        case .requestToDeleteObservation:
            return Color.Blue.PALE
        case .reviewObservationCloseOut:
            return Color.Orange.PALE
        }
    }
}
