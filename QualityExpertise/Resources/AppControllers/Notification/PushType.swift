//
//  PushType.swift
// QualityExpertise
//
//  Created by developer on 17/03/22.
//

import Foundation

enum PushType: Int, Codable, CaseIterable {
    case notification = 1
    case pendingAction = 2
}
