//
//  PendingActionType.swift
// QualityExpertise
//
//  Created by developer on 02/03/22.
//

import Foundation
import SwiftUI

enum PendingActionType: Int, CaseIterable, Codable {
    case openObservation = 1
    case requestToJoinGroup
    case observationResponsibilityChange
    case requestToDeleteObservation
    case reviewObservationCloseOut
    
    var description: String {
        switch self {
        case .openObservation:
            return "open_observation".localizedString()
        case .requestToJoinGroup:
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
        case .requestToJoinGroup:
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
        case .requestToJoinGroup:
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
