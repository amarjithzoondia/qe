//
//  Observation+Extension.swift
// ALNASR
//
//  Created by developer on 10/02/22.
//

import Foundation
import SwiftUI

extension Observation {
    enum Status: Int, Codable {
        case allObservations = -1
        case openObservations = 1
        case closedObservations = 2
        case closeOutApproved = 3
        
        var description: String {
            switch self {
            case .allObservations:
                return ""
            case .openObservations:
                return "Open"
            case .closedObservations:
                return "Closeout Pending"
            case .closeOutApproved:
                return "Closed"
            }
        }
        
        var backGroundColor: Color {
            switch self {
            case .allObservations:
                return Color.clear
            case .openObservations:
                return Color.Red.CORAL
            case .closedObservations:
                return Color(hex: "f6a03a")
            case .closeOutApproved:
                return Color.Green.LEAFY
            }
        }
    }
}
