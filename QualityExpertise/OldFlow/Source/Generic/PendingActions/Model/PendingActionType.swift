//
//  PendingActionType.swift
// ALNASR
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
            return "Open Observation"
        case .requestToJoinGroup:
            return "Request to Join group"
        case .observationResponsibilityChange:
            return "Observation Resposibility Change"
        case .requestToDeleteObservation:
            return "Request to Delete Observation"
        case .reviewObservationCloseOut:
            return "Review Observation Closeout"
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
