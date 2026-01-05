//
//  RoleResponse.swift
//  QualityExpertise
//
//  Created by Amarjith B on 12/06/25.
//

struct DashboardResponse: Decodable {
    let isGroupAdmin: Bool?
    let isSuccess: Bool
    let pendingActionsCount: Int
    let notificationCount: Int
}
